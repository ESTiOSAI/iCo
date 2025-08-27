//
//  ReconnectableSocket.swift
//  AIProject
//
//  Created by kangho lee on 8/17/25.
//

import Foundation
import AsyncAlgorithms

public actor ReconnectableWebSocketClient<Base: SocketEngine>: SocketEngine {
    private var stateChannel: AsyncChannel<WebSocket.State>
    private var incomingChannel: AsyncChannel<Result<Data, WebSocket.MessageFailure>>
    
    private var attempts: Int = 0
    
    private var base: Base?
    private var forwardStateTask: Task<Void, Never>?
    private var forwardIncomingTask: Task<Void, Never>?
    private var loopTask: Task<Void, Never>?
    
    private var isClosed = true
    
    private var backoff: ExponentialBackoff
    private let policy: ReconnectPolicy
    private let makeBase: () -> Base
    
    public nonisolated var state: AsyncStream<WebSocket.State> {
        AsyncStream { continuation in
            Task {
                for await state in await stateChannel {
                    continuation.yield(state)
                }
                continuation.finish()
            }
        }
    }
    
    public nonisolated var incoming: AsyncStream<Result<Data, WebSocket.MessageFailure>> {
        AsyncStream { continuation in
            Task {
                for await message in await incomingChannel {
                    continuation.yield(message)
                }
                continuation.finish()
            }
        }
    }
    
    public init(makeBase: @escaping () -> Base, policy: ReconnectPolicy = .defaultPolicy()) {
        self.makeBase = makeBase
        self.policy = policy
        self.backoff = ExponentialBackoff(policy: policy)
        
        self.stateChannel = .init()
        self.incomingChannel = .init()
        
        debugPrint(String(describing: Self.self), "init")
    }
    
    public func connect() async {
        guard loopTask == nil else { return }
        isClosed = false
        loopTask?.cancel()
        loopTask = Task { [weak self] in
            do {
               try await self?.runLoop()
            } catch {
                await self?.loopTask?.cancel()
                await self?.close()
            }
        }
    }
    
    public func close() async {
        isClosed = true
        forwardStateTask?.cancel()
        forwardIncomingTask?.cancel()
        await base?.close()
        base = nil
        
        release()
    }
    
    public func send(_ data: Data) async throws {
        try await base?.send(data)
    }
    
    deinit {
        debugPrint(String(describing: Self.self), #function)
        forwardStateTask?.cancel()
        forwardIncomingTask?.cancel()
            
        base = nil
        
        stateChannel.finish()
        incomingChannel.finish()
        loopTask?.cancel()
        loopTask = nil
    }
    
    private func runLoop() async throws {
        while !isClosed {
            let base = makeBase()
            self.base = base
            
            self.stateChannel = .init()
            self.incomingChannel = .init()
            
            forwardStateTask?.cancel()
            forwardIncomingTask?.cancel()
            
            forwardStateTask = Task { [weak self] in await self?.forwardState(from: base) }
            
            forwardIncomingTask = Task { [weak self] in await self?.forwardIncoming(from: base) }
            
            await base.connect()
            
            let terminal = await waitTerminalEvent(from: base)
            
            if isClosed { break }
            
            switch classify(closeCode: terminal.closeCode, error: terminal.error) {
            case let .closed(code, reason):
                await stateChannel.send(.closed(code: code, reason: reason))
                release()
                return
            case .nonRetryable(let error):
                await stateChannel.send(.failed(error ?? URLError(.networkConnectionLost)))
                release()
                return
            case .retryable:
                let delay = backoff.next()
                print(backoff.attempt)
                attempts += 1
                print("object's attemps: \(attempts) after \(delay) sec.")
                await stateChannel.send(.reconnecting(nextAttempsIn: delay))
                try await Task.sleep(for: delay)
            }
        }
    }
    
    private func classify(closeCode: URLSessionWebSocketTask.CloseCode?,
                          error: Error?) -> WebSocket.Failure {
//        if closeCode == nil, error == nil {
//            return .closed(code: .normalClosure, reason: nil)
//        }
        if let code = closeCode {
            switch code {
                // 일시적 - 재시도
            case .goingAway, .abnormalClosure, .internalServerError, .noStatusReceived:
                return .retryable(underlying: error)
                // 정상 종료
            case .normalClosure:
                return .closed(code: code, reason: nil)
                // 정책/프로토콜/보안 - 비재시도
            case .protocolError, .unsupportedData, .policyViolation, .messageTooBig, .tlsHandshakeFailure, .invalidFramePayloadData, .invalid, .mandatoryExtensionMissing:
                return .nonRetryable(underlying: error)
            default:
                return .retryable(underlying: error)
            }
        }
        
        if let urlErr = error as? URLError {
            switch urlErr.code {
                // 일시적 네트워크
            case .notConnectedToInternet, .timedOut, .networkConnectionLost:
                return .retryable(underlying: urlErr)
                
                // 앱 전환/작업 취소 등
            case .cancelled:
                return .retryable(underlying: urlErr)
                
                // 환경/설정/서버 응답 이상은 보수적으로 비재시도
            case .cannotFindHost, .cannotConnectToHost, .badServerResponse, .secureConnectionFailed, .serverCertificateUntrusted, .serverCertificateHasBadDate, .serverCertificateHasUnknownRoot:
                return .nonRetryable(underlying: urlErr)
            default:
                return .retryable(underlying: urlErr)
            }
        }
        
        // 알 수 없으면 재시도 쪽으로
        return .retryable(underlying: error)
    }
    
    private func forwardState(from base: Base) async {
        for await _state in base.state {
            switch _state {
            case .connecting:
                await stateChannel.send(.connecting)
            case .connected:
                backoff.reset()
                await stateChannel.send(.connected)
            case .failed(let error):
                await stateChannel.send(.failed(error))
            case .closed(let code, let reason):
                await stateChannel.send(.closed(code: code, reason: reason))
            case .reconnecting:
                break
            }
        }
    }
    
    private func forwardIncoming(from base: Base) async {
        for await message in base.incoming {
            await incomingChannel.send(message)
        }
    }
    
    private func waitTerminalEvent(from base: Base) async -> (closeCode: URLSessionWebSocketTask.CloseCode?, error: Error?) {
        for await _state in base.state {
            switch _state {
            case .failed(let error):
                return (nil, error)
            case .closed(let code, let reason):
                var reasonString: String = "내용 없음"
                if let reason, let text = String(data: reason, encoding: .utf8) {
                    reasonString = text
                }
                debugPrint(reasonString)
                return (code, nil)
            default: continue
            }
        }
        
        return (nil, nil)
    }
    
    private func release() {
        forwardStateTask?.cancel()
        forwardIncomingTask?.cancel()
        
        base = nil
        
        stateChannel.finish()
        incomingChannel.finish()
        loopTask?.cancel()
        loopTask = nil
    }
}
