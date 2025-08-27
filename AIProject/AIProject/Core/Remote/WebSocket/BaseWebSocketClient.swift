//
//  BaseWebSocketClient.swift
//  AIProject
//
//  Created by kangho lee on 8/17/25.
//

import Foundation
import AsyncAlgorithms

public final actor BaseWebSocketClient: NSObject, SocketEngine {
    
    private var stateChannel: AsyncChannel<WebSocket.State>
    private var incomingChannel: AsyncChannel<Result<Data, WebSocket.MessageFailure>>
    
    private let url: URL
    private let session: URLSession
    private var task: URLSessionWebSocketTask?
    
    private var healthCheck: Task<Void, Never>?
    
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
    
    public init(url: URL, session: URLSession = .shared) {
        
        self.url = url
        self.session = session
        
        stateChannel = AsyncChannel<WebSocket.State>()
        incomingChannel = AsyncChannel<Result<Data, WebSocket.MessageFailure>>()
        
        super.init()
        debugPrint(String(describing: Self.self), #function)
    }
    
    public func connect() async {
        
        stateChannel = .init()
        incomingChannel = .init()
        
        await stateChannel.send(.connecting)
        
        self.task = session.webSocketTask(with: url)
        task?.delegate = self
        task?.resume()
        
        try? await sendPing()
    }
    
    public func send(_ data: Data) async throws {
        do {
            try await task?.send(.data(data))
        } catch {
            await handleClose(with: error)
        }
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
            } catch is CancellationError {
                await handleClose(code: .normalClosure, reason: nil)
                return
            } catch {
                if (error as NSError).code == 57 {
                    debugPrint("WebSocekt is not connected Error 57")
                    await handleClose(with: NetworkError.webSocketError)
                    return
                } else if let urlError = error as? URLError, urlError.code == .cancelled {
                    await handleClose(code: .normalClosure, reason: nil)
                } else {
                    await handleClose(with: error)
                    return
                }
            }
        }
    }
    
    private func handleClose(with error: Error) async {
        guard task != nil else { return }
        
        await stateChannel.send(.failed(error))
        release()
    }
    
    private func handleClose(code: URLSessionWebSocketTask.CloseCode, reason: Data?) async {
        guard task != nil else { return }
        
        await stateChannel.send(.closed(code: code, reason: reason))
        
        Task.detached { [weak self] in
            await self?.release()
        }
    }
    
    func release() {
        task = nil
        
        healthCheck?.cancel()
        healthCheck = nil
        stateChannel.finish()
        incomingChannel.finish()
    }
    
    /// 인터벌마다 핑 보내는 메소드
    private func checkingAlive(duration: Duration) {
        self.healthCheck?.cancel()
        
        self.healthCheck = Task {
                while task != nil {
                    do {
                        try await Task.sleep(for: duration, clock: .suspending)
                        try await sendPing()
                    } catch {
                        await handleClose(with: error)
                        break
                    }
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
        await stateChannel.send(.connected)
        
        Task {
            await receiveLoop()
        }
        
        checkingAlive(duration: .seconds(10))
    }
}

extension BaseWebSocketClient: URLSessionWebSocketDelegate {
    public nonisolated func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        debugPrint("didOpen")
        Task {
            await handleConnect()
        }
    }
    
    public nonisolated func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        debugPrint("didClose")
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
