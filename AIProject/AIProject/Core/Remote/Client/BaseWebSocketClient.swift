//
//  BaseWebSocketClient.swift
//  AIProject
//
//  Created by kangho lee on 8/17/25.
//

import Foundation
import AsyncAlgorithms

public final class BaseWebSocketClient: NSObject, SocketEngine {
    
    public let state: AsyncStream<WebSocket.State>
    public let incoming: AsyncStream<Result<Data, WebSocket.MessageFailure>>
    
    private let stateChannel: AsyncChannel<WebSocket.State>
    private let incomingChannel: AsyncChannel<Result<Data, WebSocket.MessageFailure>>
    
    private let url: URL
    private let session: URLSession
    private var task: URLSessionWebSocketTask?
    
    private var healthCheck: Task<Void, Error>?
    
    public init(url: URL, session: URLSession = .shared) {
        self.url = url
        self.session = session
        
        stateChannel = AsyncChannel<WebSocket.State>()
        incomingChannel = AsyncChannel<Result<Data, WebSocket.MessageFailure>>()
        
        state = stateChannel.makeStream()
        
        incoming = incomingChannel.makeStream()
    }
    
    public func connect() async {
        await stateChannel.send(.connecting)
        
        self.task = session.webSocketTask(with: url)
        task?.delegate = self
        task?.resume()
        
        try? await sendPing()
    }
    
    public func send(_ data: Data) async throws {
        try await task?.send(.data(data))
    }
    
    public func close() async {
        guard let task else {
            await handleClose(code: .normalClosure, reason: nil)
            return
        }
        task.cancel(with: .normalClosure, reason: nil)
    }
    
    deinit {
        debugPrint(String(describing: Self.self), #function)
        task?.cancel()
        task = nil
        stateChannel.finish()
        incomingChannel.finish()
    }
    
    private func receiveLoop() async {
        guard let task else { return }
        while true {
            do {
                let message = try await task.receive()
                
                switch message {
                case .data(let data):
                    await incomingChannel.send(.success(data))
                case .string(let string):
                    await incomingChannel.send(.success(Data(string.utf8)))
                @unknown default:
                    await incomingChannel.send(.failure(.frameCorrupted))
                }
            } catch {
                if let urlError = error as? URLError, urlError.code == .cancelled {
                    await handleClose(code: .normalClosure, reason: nil)
                } else {
                    await stateChannel.send(.failed(error))
                    await handleClose(with: error)
                    return
                }
            }
        }
    }
    
    private func handleClose(with error: Error) async {
        guard task != nil else { return }
        
        await stateChannel.send(.closed(code: .abnormalClosure, reason: nil))
        release()
    }
    
    private func handleClose(code: URLSessionWebSocketTask.CloseCode, reason: Data?) async {
        guard task != nil else { return }
        debugPrint("didClose")
        
        await stateChannel.send(.closed(code: code, reason: reason))
        release()
    }
    
    func release() {
        task = nil
        
        stateChannel.finish()
        incomingChannel.finish()
    }
    
    /// 인터벌마다 핑 보내는 메소드
    private func checkingAlive(duration: Duration) {
        self.healthCheck?.cancel()
        
        self.healthCheck = Task {
            while task != nil {
                try await Task.sleep(for: duration, clock: .suspending)
                try await sendPing()
            }
        }
    }
    
    private func sendPing() async throws {
        guard let task else { return }
        
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            debugPrint("Send Ping")
            task.sendPing { error in
                if let error {
                    continuation.resume(throwing: error)
                    debugPrint("Ping Failed: \(error)")
                    return
                }
                debugPrint("Received Pong")
                continuation.resume()
            }
        }
    }
    
    private func handleConnect() async {
        debugPrint("didOpen")
        await stateChannel.send(.connected)
        
        Task {
            await receiveLoop()
        }
        
        checkingAlive(duration: .seconds(120))
    }
}

extension BaseWebSocketClient: URLSessionWebSocketDelegate {
    public func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        Task {
            await handleConnect()
        }
    }
    
    public func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        Task {
            await handleClose(code: closeCode, reason: reason)
        }
    }
}

extension AsyncChannel {
    public func makeStream() -> AsyncStream<Element> {
        AsyncStream<Element> { continuation in
            Task {
                for await value in self {
                    continuation.yield(value)
                }
                continuation.finish()
            }
        }
    }
}
