//
//  WebSocketClient.swift
//  AIProject
//
//  Created by 강대훈 on 7/30/25.
//

import Foundation
import AsyncAlgorithms

/// 웹소켓 통신을 담당하는 객체
final actor WebSocketClient2: NSObject {
    
    /// URLSession 웹소켓 태스크
    private var webSocketTask: URLSessionWebSocketTask?
    private var eventChannel = AsyncChannel<Event>()
    private var messageChannel = AsyncChannel<URLSessionWebSocketTask.Message>()
    
    /// 소켓 연결 상태 확인
    private var isActive = false
    private var isForced = false
    
    /// 비동기 데이터를 방출할 스트림
    private var healthCheck: Task<Void, Error>?
    
    private let pingInterval: Duration
    
    // MARK: - Public
    
    init(pingInterval duration: Duration = .seconds(120)) {
        self.pingInterval = duration
        super.init()
        
        Task {
            await handleEvent()
        }
    }
    
    /// 웹소켓 연결을 시작합니다.
    func connect(endpoint: URL = EndPoint.upbit.url) async {
        
        let session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
        
        self.webSocketTask = session.webSocketTask(with: endpoint)  // (웹소켓) 작업 저장
        self.webSocketTask?.resume()
        
        messageChannel = .init()
        await eventChannel.send(.connecting)
        
        isForced = false
    }
    
    /// 유저가 웹소켓 연결을 종료합니다.
    func disconnect(closeCode: URLSessionWebSocketTask.CloseCode = .normalClosure, reason: String? = nil) {
        webSocketTask?.cancel(with: closeCode, reason: reason?.data(using: .utf8))
        webSocketTask = nil
        
        isForced = true
    }
    
    func send(text: String) async throws {
        guard isActive, let webSocketTask else {
            await eventChannel.send(.error("send", SocketError.notConnected))
            return
        }
        try await webSocketTask.send(.string(text))
    }
    
    func send(data: Data) async throws {
        guard isActive, let webSocketTask else {
            await eventChannel.send(.error("send", SocketError.notConnected))
            return
        }
        try await webSocketTask.send(.data(data))
    }
    
    func stream() -> AsyncStream<URLSessionWebSocketTask.Message> {
        AsyncStream { continuation in
            Task {
                for await message in self.messageChannel {
                    continuation.yield(message)
                }
                continuation.finish()
            }
        }
    }
    
    deinit {
        isActive = false
        webSocketTask?.cancel()
        webSocketTask = nil
        healthCheck?.cancel()
        healthCheck = nil
        messageChannel.finish()
        eventChannel.finish()
    }
    
    // MARK: - Private
    
    private func handleEvent() async {
            for await event in eventChannel {
                switch event {
                case .connecting:
                    debugPrint("Connecting...")
                case .connected:
                    debugPrint("Connected")
                    handleConnected()
                case .disconnected(let code, let reason):
                    debugPrint("DisConnected")
                    handleDisconnect(code: code, reason: reason)
                case .complete(let error):
                    debugPrint("Socket Completed with: \(String(describing: error))")
                case .error(let phase, let error):
                    handleDisconnect(with: error, phase: phase)
                }
            }
    }
    
    /// session으로부터 connected 응답을 받은 후 실행됩니다. message 수신을 시작하고, interval마다 ping을 보냅니다.
    private func handleConnected() {
        guard !isActive, let webSocketTask else {
            Task {
                await eventChannel.send(.error(#function, SocketError.alreadyConnected))
            }
            return
        }
        isActive = true
        
        Task {
            do {
                while isActive {
                    let message = try await webSocketTask.receive()
                    await messageChannel.send(message)
                }
            } catch {
                await eventChannel.send(.error("message", error))
            }
        }
        
        checkingAlive(duration: self.pingInterval)
    }
    
    /// 120초마다 핑 보내는 메소드 - Upbit 기준
    /// 초마다 핑 보내는 메소드
    private func checkingAlive(duration: Duration) {
        self.healthCheck?.cancel()
        
        self.healthCheck = Task.detached {
            while await self.isActive {
                try await self.sendPing()
                try await Task.sleep(for: duration, clock: .suspending)
            }
        }
    }
    
    private func handleDisconnect(with error: Error?, phase: String) {
//        debugPrint(#function, "phase: \(phase), \(error)")
        
        guard isActive else {
            debugPrint("Already Disconnected")
            return
        }
        
        release()
    }
    
    private func handleDisconnect(code: URLSessionWebSocketTask.CloseCode, reason: String) {
        debugPrint(#function, "code: \(code), reason: \(reason)")
        
        guard isActive else {
            debugPrint("Already Disconnected")
            return
        }
        
        release()
    }
    
    private func release() {
        
        isActive = false
        healthCheck?.cancel()
        healthCheck = nil
        
        messageChannel.finish()
    }
    
    private func sendPing() async throws {
        guard isActive, let socket = webSocketTask else {
            await eventChannel.send(.error(#function, SocketError.notConnected))
            return
        }
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            debugPrint("Send Ping")
            socket.sendPing { error in
                if let error {
                    continuation.resume(throwing: SocketError.pingError(error))
                    debugPrint("Ping Failed: \(error)")
                    return
                }
                continuation.resume()
            }
        }
    }
}

extension WebSocketClient2: URLSessionWebSocketDelegate {
    /// 웹 소켓 연결 시작
    nonisolated func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        
        Task {
            await eventChannel.send(.connected)
        }
    }
    
    /// 웹 소켓 연결 종료
    nonisolated func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        var r = ""
        if let reason, let string = String(data: reason, encoding: .utf8) {
            r = string
        }
        print("DidClose reason: \(r) code: \(closeCode)")
        Task {
            await eventChannel.send(.disconnected(code: closeCode, reason: r))
        }
    }
    
    nonisolated func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: (any Error)?) {
        Task {
            await eventChannel.send(.complete(error))
        }
    }
}

