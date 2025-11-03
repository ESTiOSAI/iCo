//
//  WebSocket+ConnectTest.swift
//  iCoTests
//
//  Created by 강대훈 on 11/3/25.
//

import XCTest
import AsyncAlgorithms
@testable import iCo

public final class MockWebSocketClient: WebSocketProvider {
    private var stateStream: AsyncStream<WebSocket.State>
    private(set) var connectCallCount: Int = 0
    private(set) var reconnectCallCount: Int = 0
    
    public var stateBroadCaster: AsyncStreamBroadcaster<WebSocket.State>
    public var incomingChannel: AsyncChannel<URLSessionWebSocketTask.Message>
    
    private var stateTask: Task<Void, Never>?
    
    init() {
        stateBroadCaster = .init()
        stateStream = stateBroadCaster.stream()
        incomingChannel = AsyncChannel<URLSessionWebSocketTask.Message>()
        
        observeState()
    }
    
    public func connect() async {
        await stateBroadCaster.send(.connecting)
        try? await Task.sleep(for: .milliseconds(100))
        await stateBroadCaster.send(.connected)
        connectCallCount += 1
    }
    
    public func disconnect() async {
        await stateBroadCaster.send(.closed)
    }
    
    public func disconnectWithError() async {
        // disconnectWithError -> 0.1초 -> reconnect send -> reconnect 함수 호출 -> ~~초 기다렸다가 -> connect
        try? await Task.sleep(for: .milliseconds(100))
        await stateBroadCaster.send(.reconnecting(nextAttempsIn: .milliseconds(200)))
    }
    
    public func send(text: String) async throws {
        
    }
    
    public func send(data: Data) async throws {
        
    }
    
    private func observeState() {
        stateTask = Task {
            for await state in stateStream {
                switch state {
                case .connecting:
                    continue
                case .connected:
                    receive()
                    checkingAlive()
                case .failed, .closed:
                    release()
                case .reconnecting:
                    await reconnect()
                }
            }
        }
    }
    
    private func receive() {
        
    }
    
    private func checkingAlive() {
        
    }
    
    private func release() {
        
    }
    
    private func reconnect() async {
        reconnectCallCount += 1
        try? await Task.sleep(for: .milliseconds(100))
        await connect()
    }
}

final class WebSocket_ConnectTest: XCTestCase {
    var sut: RealTimeTickerProvider!
    var socket: MockWebSocketClient!

    override func setUpWithError() throws {
        socket = MockWebSocketClient()
        sut = UpbitTickerService(client: socket!)
    }

    override func tearDownWithError() throws {
        socket = nil
        sut = nil
    }
    
    func test_커넥트_연결됐을때() async {
        await sut.connect()
        XCTAssertEqual(1, socket.connectCallCount)
    }
    
    func test_연결끊김시에_자동으로재연결되는지() async {
        await sut.connect()
        XCTAssertEqual(1, socket.connectCallCount)
        await socket.disconnectWithError()
        try? await Task.sleep(for: .seconds(0.5))
        XCTAssertEqual(2, socket.connectCallCount)
        XCTAssertEqual(1, socket.reconnectCallCount)
    }
}
