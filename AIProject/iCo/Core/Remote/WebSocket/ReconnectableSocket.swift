//
//  ReconnectableSocket.swift
//  AIProject
//
//  Created by kangho lee on 8/17/25.
//

import Foundation
import AsyncAlgorithms

/// Socket을 상태와 메세지를 포워딩하고 재연결을 책임집니다.
public class ReconnectableWebSocketClient<Base: SocketEngine> {
    /// 시도한 횟수
    private var attempts: Int = 0
    
    /// SocketEngine Protocol
    private var base: Base?
    
    /// 소켓 상태 재연결하기 위한 Loop
    private var loopTask: Task<Void, Never>?
    
    /// 소켓 연결 상태 flag
    private var isClosed = true
    
    /// 지수적으로 증가하는 재연결 대기
    private var backoff: ExponentialBackoff
    
    /// 재연결 정책
    private let policy: ReconnectPolicy
    
    /// 소켓은 재사용하기 어렵기 때문에 closure로 캡처하여 재연결 시 사용
    private let makeBase: () -> Base
    
    typealias IncomeStream = AsyncStream<Result<Data, WebSocket.MessageFailure>>
    var stream: IncomeStream?
    var incomeContinuation: IncomeStream.Continuation?

    public init(makeBase: @escaping () -> Base, policy: ReconnectPolicy = .defaultPolicy()) {
        self.makeBase = makeBase
        self.policy = policy
        self.backoff = ExponentialBackoff(policy: policy)
        
        stream = IncomeStream { continuation in
            incomeContinuation = continuation
        }
    }
    
    /// 소켓 연결 및 재연결 loop 실행
    public func connect() async {
        guard loopTask == nil else { return }
        isClosed = false
        loopTask?.cancel()
        loopTask = Task {
            do {
               try await runLoop()
            } catch {
                loopTask?.cancel()
                await close()
            }
        }
    }
    
    public func close() async {
        isClosed = true
        await base?.close()
        base = nil
        
        release()
    }
    
    public func send(_ data: Data) async throws {
        try await base?.send(data)
    }
    
    deinit {
        debugPrint(String(describing: Self.self), #function)

        base = nil
        loopTask?.cancel()
        loopTask = nil
    }
    
    /// 소켓을 재연결하기 위한 loop입니다.
    /// 소켓이 죽으면 종료 원인을 분기하여 재시도 또는 종료합니다.
    private func runLoop() async throws {
        while !isClosed {
            let base = makeBase()
            self.base = base
            await base.connect()
            
            Task { await observeData() }
                
            // 소켓이 종료될 때 까지 대기 및 종료 원인 응답 대기
            let terminal = await waitTerminalEvent(from: base)
            
            // 사용자가 종료한 것이면 그냥 종료
            if isClosed {
                break
            }
            
            // 종료 원인 분기
            switch classify(closeCode: terminal.closeCode, error: terminal.error) {
            case .closed:
                release()
                return
            case .nonRetryable:
                release()
                return
            case .retryable:
                let delay = backoff.next()
                attempts += 1
                try await Task.sleep(for: delay)
            }
        }
    }
    
    private func observeData() async {
        guard let base else { return }
        
        for await value in base.incomingChannel {
            incomeContinuation?.yield(value)
        }
    }
    
    
    /// 종료 원인 분기
    /// - Parameters:
    ///   - closeCode: 종료 코드 // 1000 정상 종료등
    ///   - error: urlError // 네트워크 연결 에러 등
    /// - Returns: 에러타입 반환 예) retryable , closed, nonRetryable
    private func classify(closeCode: URLSessionWebSocketTask.CloseCode?,
                          error: Error?) -> WebSocket.Failure {
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
    
    private func waitTerminalEvent(from base: Base) async -> (closeCode: URLSessionWebSocketTask.CloseCode?, error: Error?) {
        for await state in base.stateChannel {
            print(#function, state)
            switch state {
            case .failed(let error):
                return (nil, error)
            case .closed(let code, _):
                return (code, nil)
            default:
                continue
            }
        }
        
        return (nil, nil)
    }
    
    private func release() {
        base = nil
        loopTask?.cancel()
        loopTask = nil
    }
}
