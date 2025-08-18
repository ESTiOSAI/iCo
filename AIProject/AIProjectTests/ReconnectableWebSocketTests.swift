//
//  ReconnectableWebSocketTests.swift
//  AIProjectTests
//
//  Created by kangho lee on 8/17/25.
//

import XCTest
import AIProject
import AsyncAlgorithms

final class ReconnectableWebSocketTests: XCTestCase {
    static let echoURL = URL(string: "wss://echo.websocket.org")!
    static let upbitURL = URL(string: "wss://api.upbit.com/websocket/v1")!

    func test_connect() async throws {
        let socket = ReconnectableWebSocketClient {
            MockWebSocketClient(.connecting)
        }
        
        var states = [WebSocket.State]()
        
        Task {
            for await state in await socket.state {
                states.append(state)
            }
        }
        
        await socket.connect()
        
        try await Task.sleep(for: .milliseconds(100))
        
        let expect = [WebSocket.State.connecting, .connected]
        XCTAssertEqual(states, expect)
    }
    
    func test_normalDisconnect() async throws {
        let socket = ReconnectableWebSocketClient {
            BaseWebSocketClient(url: Self.upbitURL)
        }
        
        var states = [WebSocket.State]()
        
        Task {
            for await state in await socket.state {
                states.append(state)
            }
        }
        
        await socket.connect()
        try await Task.sleep(for: .milliseconds(100))
        
        await socket.close()
        
        let expected: [WebSocket.State] = [.connecting, .connected, .closed(code: .normalClosure, reason: nil)]
        XCTAssertEqual(states, expected)
    }
    
    func test_reconnect_test() async throws {
        let socket = ReconnectableWebSocketClient {
            MockWebSocketClient(.closed(code: .abnormalClosure, reason: nil))
        }
        
        var states = [WebSocket.State]()
        
        Task {
            for await state in await socket.state {
                states.append(state)
            }
        }
        
        await socket.connect()
        
        try await Task.sleep(for: .milliseconds(300))
        
        let expected: [WebSocket.State] = [.connecting, .connected, .reconnecting(nextAttempsIn: .milliseconds(100))]
        XCTAssertEqual(states, expected)
    }
    
    func test_nonReconnectable_test() async throws {
        let socket = ReconnectableWebSocketClient {
            MockWebSocketClient(.failed(URLError(.cannotFindHost)))
        }
        
        var states = [WebSocket.State]()
        
        Task {
            for await state in await socket.state {
                states.append(state)
            }
        }
        
        await socket.connect()
        
        try await Task.sleep(for: .milliseconds(300))
        
        let expected: [WebSocket.State] = [.connecting, .connected, .failed(URLError(.cannotFindHost))]
        XCTAssertEqual(states, expected)
    }
    
    func test_retryFailed_exceed_attemps() async throws {
        let socket = ReconnectableWebSocketClient {
            MockWebSocketClient()
        }
        
        var states = [WebSocket.State]()
        
        Task {
            for await state in await socket.state {
                states.append(state)
            }
        }
        
        await socket.connect()
        
        try await Task.sleep(for: .milliseconds(300))
        
        XCTAssertEqual(states,[ .failed(WebSocket.RetryFailure.exceedAttemps)])
    }
}

private final actor MockWebSocketClient: SocketEngine {
    let state: AsyncStream<WebSocket.State>
    let incoming: AsyncStream<Result<Data, WebSocket.MessageFailure>>
    let stateChannel = AsyncChannel<WebSocket.State>()
    let incomingChannel = AsyncChannel<Result<Data, WebSocket.MessageFailure>>()
    
    let testResult: WebSocket.State
    
    var isOnce = true
    
    init(_ testResult: WebSocket.State = .failed(URLError(.cancelled))) {
        state = stateChannel.makeStream()
        incoming = incomingChannel.makeStream()
        self.testResult = testResult
    }
    
    deinit {
        print("\(String(describing: Self.self))", #function)
        stateChannel.finish()
        incomingChannel.finish()
    }
    
    func connect() async {
        if isOnce {
            await stateChannel.send(.connecting)
            await stateChannel.send(.connected)
            isOnce = false
            Task {
                try await Task.sleep(for: .milliseconds(100))
                await stateChannel.send(testResult)
            }
        }
        
    }
    
    func close() async {
        await stateChannel.send(.closed(code: .normalClosure, reason: nil))
    }
    
    func send(_ data: Data) async throws {
        
    }
}
