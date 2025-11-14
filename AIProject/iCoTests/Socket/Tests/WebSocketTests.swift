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
    var sut: WebSocketClient!
    var task: MockWebSocketTask!
    var urlSession: MockURLSession!
    
    override func setUp() async throws {
        task = MockWebSocketTask()
        broadCaster = MockAsyncStreamBroadCaster()
        urlSession = MockURLSession(task: task)
        sut = WebSocketClient(url: url, session: urlSession, stateBroadCaster: broadCaster)
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
            .reconnecting,
            .connecting,
            .connected
        ]
        
        // act
        await sut.connect()
        task.disconnect(with: .internalServerError)
        try? await Task.sleep(for: .seconds(4))
        
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
            .reconnecting,
            .connecting,
            .connected
        ]
        
        await sut.connect()
        task.disconnect()
        try? await Task.sleep(for: .seconds(4))
        
        XCTAssertEqual(expectedLog, broadCaster.log)
        XCTAssertNotNil(sut.task)
        XCTAssertNotNil(sut.stateTask)
        XCTAssertNotNil(sut.receiveTask)
        XCTAssertNotNil(sut.healthCheck)
    }
    
    func testSend_Failed_notConnected() async throws {
        let value: ()? = try? await sut.send(text: "Hello")
        XCTAssertNil(value)
    }
    
    func testSend_Success() async throws {
        let values = ["Hello", "Swift", "Test"]
        
        await sut.connect()
        
        try await sut.send(text: values[0])
        try await sut.send(text: values[1])
        try await sut.send(text: values[2])
        
        if case .string(let text) = task.messages[1] {
            XCTAssertEqual(text, values[1])
        } else {
            XCTFail("not found")
        }
        
        XCTAssertEqual(task.sendCallCount, 3)
        XCTAssertEqual(task.messages.count, 3)
    }
    
    func testSend_dataSucess() async throws {
        await sut.connect()
        
        try await sut.send(data: Data("Hello".utf8))
        
        if case .data(let encoded) = task.messages[0] {
            XCTAssertEqual("Hello", String(data: encoded, encoding: .utf8))
        } else {
            XCTFail("not found")
        }
        
        XCTAssertEqual(task.sendCallCount, 1)
    }
    
    func testPing_Failed_notConnected() async throws {
        let exp = expectation(description: "Wait for request")
        
        makeSUTError()
        task.sendPing { error in
            XCTAssertNotNil(error)
            exp.fulfill()
        }
        
        await fulfillment(of: [exp], timeout: 0.3)
    }
    
    func testPing_Failed_pingTimeout() async throws {
        let exp = expectation(description: "Wait for request")
        
        makeSUTError()
        await sut.connect()
        task.sendPing { error in
            XCTAssertNotNil(error)
            exp.fulfill()
        }
        
        await fulfillment(of: [exp], timeout: 0.3)
    }
    
    func testPing_Success() async throws {
        let exp = expectation(description: "Wait for request")
        
        await sut.connect()
        
        task.sendPing { error in
            XCTAssertNil(error)
            exp.fulfill()
        }
        
        await fulfillment(of: [exp], timeout: 0.3)
    }
}

extension WebSocketTests {
    private func makeSUTError() {
        task = MockWebSocketTask(throwError: true)
        broadCaster = MockAsyncStreamBroadCaster()
        urlSession = MockURLSession(task: task)
        sut = WebSocketClient(url: url, session: urlSession, stateBroadCaster: broadCaster)
    }
}
