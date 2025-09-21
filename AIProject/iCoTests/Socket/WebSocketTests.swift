//
//  WebSocketTests.swift
//  AIProjectTests
//
//  Created by kangho lee on 8/17/25.
//

import XCTest
@testable import iCo

// hook test
final class WebSocketTests: XCTestCase {
    
    static let echoURL = URL(string: "wss://echo.websocket.org")!
    static let upbitURL = URL(string: "wss://api.upbit.com/websocket/v1")!

    func test_connect() async throws {
        var (socket, states) = makeSUT()
        
        Task {
            for await state in socket.state {
                states.append(state)
            }
        }
        
        await socket.connect()
        XCTAssertEqual(states, [.connecting, .connected])
    }
    
    func test_user_disconnect() async throws {
        var (socket, states) = makeSUT()
        
        Task {
            for await state in socket.state {
                states.append(state)
            }
        }
        
        await socket.connect()
        await socket.close()
        try await Task.sleep(for: .milliseconds(100))
        XCTAssertEqual(states, [.connecting, .connected, .closed(code: .normalClosure, reason: nil)])
    }
    
    // MARK: Helper
    
    private func makeSUT(url: URL = upbitURL) -> (SocketEngine, [WebSocket.State]) {
        let socket = BaseWebSocketClient(url: url)
        
        return (socket, [WebSocket.State]())
    }

}
