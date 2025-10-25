//
//  BaseWebSocketClient 2.swift
//  iCo
//
//  Created by 강대훈 on 10/25/25.
//

import Foundation
import AsyncAlgorithms

public final class WebSocketClient: NSObject {
    
    /// 소켓 상태 채널
    public var stateChannel: AsyncChannel<WebSocket.State>
    
    /// 메세지 채널
    public var incomingChannel: AsyncChannel<Result<Data, WebSocket.MessageFailure>>
    
    private let url: URL
    private let session: URLSession
    private var task: URLSessionWebSocketTask?
    
    private var stateTask: Task<Void, Error>?
    private var incomingTask: Task<Void, Error>?
    
    /// 핑 전송 task
    private var healthCheck: Task<Void, Never>?
    
    public init(url: URL, session: URLSession = .shared) {
        self.url = url
        self.session = session
        
        stateChannel = AsyncChannel<WebSocket.State>()
        incomingChannel = AsyncChannel<Result<Data, WebSocket.MessageFailure>>()
        
        super.init()
        configureTask()
    }
    
    /// 채널을 새로 개설하고 소켓을 엽니다.
    /// 핑을 보내는 이유는 연결된 상태를 확정적으로 기다리기 위해서입니다.
    public func connect() async {
        self.task = session.webSocketTask(with: url)
        task?.delegate = self
        task?.resume()
        
        await stateChannel.send(.connecting)
        
        // 핑 응답은 연결 후에 오기 때문에 connected 시점을 캐치할 수 있음
        try? await sendPing()
        
        // connect 되었다 보내야 됨.
    }
    
    private func sendPing() async throws {
        return try await withCheckedThrowingContinuation { continuation in
            task?.sendPing { error in
                Task {
                    if let error {
                        debugPrint("Ping Failed: \(error)")
                        continuation.resume(throwing: error)
                        return
                    }
                    
                    continuation.resume()
                }
            }
        }
    }
    
    private func configureTask() {
        stateTask?.cancel()
        incomingTask?.cancel()
        
        stateTask = Task {
            for await value in stateChannel {
                // close, error가 왔을 때 state 초기화 로직이 있어야 함.
            }
        }
        
        incomingTask = Task {
            for await value in incomingChannel {
                print(value)
            }
        }
    }
    
    deinit {
        debugPrint(String(describing: Self.self), #function)
        task?.cancel()
        task = nil
        stateChannel.finish()
        incomingChannel.finish()
    }
}

// MARK: 웹 소켓 Delegate로 소켓 응답 및 종료 event를 받아 처리합니다.
extension WebSocketClient: URLSessionWebSocketDelegate {
    public func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        debugPrint("didOpen")
        
        Task { await stateChannel.send(.connected) }
    }
    
    public func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        debugPrint("didClose")
    }
    
    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: (any Error)?) {
        debugPrint("didCompleteWithError")
    }
}

