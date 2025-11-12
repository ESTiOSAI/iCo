//
//  WebSocketTests.swift
//  iCoTests
//
//  Created by 강대훈 on 11/12/25.
//

import XCTest
@testable import iCo

final class WebSocketTests: XCTestCase {
    let url: URL = URL(string: "wss://")!
    var broadCaster: MockAsyncStreamBroadCaster<WebSocket.State>!
    var sut: MockWebSocketClient!
    var task: MockWebSocketTask!
    var urlSession: MockURLSession!
    
    override func setUp() async throws {
        task = MockWebSocketTask()
        broadCaster = MockAsyncStreamBroadCaster()
        urlSession = MockURLSession(task: task)
        sut = MockWebSocketClient(url: url, session: urlSession, stateBroadCaster: broadCaster)
    }
    
    override func tearDown() async throws {
        urlSession = nil
        sut = nil
        task = nil
        broadCaster = nil
    }
    
    func testInit() {
        XCTAssertNil(sut.task)
        XCTAssertNil(sut.receiveTask)
        XCTAssertNil(sut.healthCheck)
        XCTAssertNotNil(sut.stateTask)
    }
    
    func testConnect() async {
        // arrange
        let expectedLog: [WebSocket.State] = [.connecting, .connected]
        
        // act
        await sut.connect()
        try? await Task.sleep(for: .seconds(0.1)) // WSS HandShake 대기
        
        // assert
        XCTAssertEqual(expectedLog, broadCaster.log)
        XCTAssertNotNil(sut.task)
        XCTAssertEqual(sut.task?.state, .running)
        XCTAssertIdentical(sut.task?.delegate, sut)
        XCTAssertEqual(1, task.resumeCallCount)
    }
    
    func testDisconnect() async {
        // arrange
        let expectedLog: [WebSocket.State] = [.connecting, .connected, .closed]
        
        // act
        await sut.connect()
        try? await Task.sleep(for: .seconds(0.2))
        await sut.disconnect()
        try? await Task.sleep(for: .seconds(0.2))
        
        // assert
        XCTAssertEqual(expectedLog, broadCaster.log)
        XCTAssertNil(sut.healthCheck)
        XCTAssertNil(sut.receiveTask)
        XCTAssertNil(sut.task)
    }
    
    func testReconnect_CloseCode를받았을때_재연결하는지() async {
        // arrange
        let expectedLog: [WebSocket.State] = [
            .connecting,
            .connected,
            .reconnecting(nextAttempsIn: .seconds(2)),
            .connecting,
            .connected
        ]
        
        // act
        await sut.connect()
        await sut.disconnectWithCloseCode()
        try? await Task.sleep(for: .seconds(3))
        
        // assert
        XCTAssertEqual(expectedLog, broadCaster.log)
        XCTAssertNotNil(sut.task)
        XCTAssertNotNil(sut.stateTask)
        XCTAssertNotNil(sut.receiveTask)
        XCTAssertNotNil(sut.healthCheck)
    }
    
    func testReconnect_CloseCode를받지못했을때_재연결하는지() async {
        // arrange
        let expectedLog: [WebSocket.State] = [
            .connecting,
            .connected,
            .reconnecting(nextAttempsIn: .seconds(2)),
            .connecting,
            .connected
        ]
        
        await sut.connect()
        await sut.disconnectWithoutCloseCode()
        try? await Task.sleep(for: .seconds(3))
        
        XCTAssertEqual(expectedLog, broadCaster.log)
        XCTAssertNotNil(sut.task)
        XCTAssertNotNil(sut.stateTask)
        XCTAssertNotNil(sut.receiveTask)
        XCTAssertNotNil(sut.healthCheck)
    }
}
