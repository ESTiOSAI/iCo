//
//  WebSocketTest.swift
//  iCoTests
//
//  Created by kangho on 10/25/25.
//

import XCTest
import iCo

final class WebSocketTest: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() async throws {
        let sut = WebSocketClient(url: URL(string: "wss://echo.websocket.org")!)
        
        await sut.connect()
        
        try await sut.send(text: "hi")
    }
    
    func testReconnenctWhenAbnormalClose() async throws {
        let sut = WebSocketClient(url: URL(string: "wss://echo.websocket.org")!)
        
        await sut.connect()
        
        try await Task.sleep(for: .seconds(2))
        
        sut.cancel(with: .abnormalClosure)
        
        try await Task.sleep(for: .seconds(2))
        
        // connecting -> connected -> abnormal close -> handleDisconnect -> reconnect
        //  .... -> abnormal close -> didCompletWithError -> reconnect
    }
    
    func testUserClose() async throws {
        let sut = WebSocketClient(url: URL(string: "wss://echo.websocket.org")!)
        
        await sut.connect()
        
        try await Task.sleep(for: .seconds(2))
        
        sut.cancel(with: .normalClosure)
        
        try await Task.sleep(for: .seconds(2))
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
}

import Foundation
import AsyncAlgorithms

public final class WebSocketClient: NSObject {
    
    /// 소켓 상태 채널
    public var stateChannel: AsyncChannel<WebSocket.State>
    
    /// 메세지 채널
    public var incomingChannel: AsyncChannel<URLSessionWebSocketTask.Message>
    
    private let url: URL
    private let session: URLSession
    private var task: URLSessionWebSocketTask?
    
    private var stateTask: Task<Void, Error>?
    private var incomingTask: Task<Void, Error>?
    private var receiveTask: Task<Void, Error>?
    
    /// 핑 전송 task
    private var healthCheck: Task<Void, Error>?
    private var pingInterval: Duration = .seconds(30)
    private var pingTimeout: Duration = .seconds(10)
    
    public init(url: URL, session: URLSession = .shared) {
        self.url = url
        self.session = session
        
        stateChannel = AsyncChannel<WebSocket.State>()
        incomingChannel = AsyncChannel<URLSessionWebSocketTask.Message>()
        
        super.init()
        
        configureTask()
    }
    
    /// 채널을 새로 개설하고 소켓을 엽니다.
    /// 핑을 보내는 이유는 연결된 상태를 확정적으로 기다리기 위해서입니다.
    public func connect() async {
        await stateChannel.send(.connecting)
        self.task = session.webSocketTask(with: url)
        task?.delegate = self
        task?.resume()
        
        // 핑 응답은 연결 후에 오기 때문에 connected 시점을 캐치할 수 있음
        do {
            try await performWithTimeout(sendPing, at: pingTimeout)
        } catch {
            await stateChannel.send(.reconnecting(nextAttempsIn: .seconds(2)))
        }
    }
    
    // TODO: 고치기
    public func send(text: String) async throws {
        try await self.task?.send(.data(Data(text.utf8)))
    }
    
    deinit {
        debugPrint(String(describing: Self.self), #function)
        task?.cancel()
        task = nil
        stateChannel.finish()
        incomingChannel.finish()
    }
}

// MARK: - Private

extension WebSocketClient {
    
    public func sendState(with state: WebSocket.State) async {
        await stateChannel.send(state)
    }
    
    public func cancel(with code: URLSessionWebSocketTask.CloseCode) {
        task?.cancel(with: code, reason: nil)
    }
}

// MARK: - Private

extension WebSocketClient {
    
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
            for await state in stateChannel {
                switch state {
                case .connecting:
                    debugPrint("connecting...")
                    break
                case .connected:
                    receive()
                    checkingAlive()
                case .failed, .closed: release()
                case .reconnecting:
                    print("in reconnecting state")
//                    release()
                    await reconnect()
                }
            }
        }
        
        incomingTask = Task {
            for await value in incomingChannel {
                if case let .string(text) = value {
                    print(text)
                }
            }
        }
    }
    
    private func receive() {
        receiveTask?.cancel()
       receiveTask = Task {
            // TODO: handle task is nil
            guard let task else { return }
            let message = try await task.receive()
            await incomingChannel.send(message)
            receive()
        }
    }
    
    private func checkingAlive() {
        healthCheck?.cancel()
        
        healthCheck = Task {
            do {
                while true {
                    try await Task.sleep(until: .now + pingInterval)
                    try await performWithTimeout(sendPing, at: .seconds(10))
                }
            } catch {
                await stateChannel.send(.reconnecting(nextAttempsIn: .seconds(2)))
            }
        }
    }
    
    private func handleDisconneted(_ userClose: Bool) async {
        if userClose {
            await stateChannel.send(.closed)
        } else {
            await stateChannel.send(.reconnecting(nextAttempsIn: .seconds(2)))
        }
    }
    
    private func reconnect() async {
        debugPrint("try reconnecting...")
        await connect()
    }
    
    private func release() {
        stateTask?.cancel()
        stateTask = nil
        receiveTask?.cancel()
        receiveTask = nil
        healthCheck?.cancel()
        healthCheck = nil
        incomingTask?.cancel()
        incomingTask = nil
        
        if task?.state == .running {
            task?.cancel(with: .goingAway, reason: nil)
        }
        task = nil
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
        
        Task { await handleDisconneted(closeCode == .normalClosure) }
    }
    
    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: (any Error)?) {
        debugPrint("didCompleteWithError")
        
        Task {
            
            await stateChannel.send(.reconnecting(nextAttempsIn: .seconds(2))) }
    }
}

