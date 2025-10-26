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
    
    func testReceiveData() async throws {
        let sut = WebSocketClient(url: URL(string: "wss://api.upbit.com/websocket/v1")!)
        let requestFormat = "[{ticket:test},{type:ticker,codes:[KRW-BTC]}]"
        
        await sut.connect()
        try await sut.send(text: requestFormat)
        try await Task.sleep(for: .seconds(3))
        
        sut.cancel()

        try await Task.sleep(for: .seconds(3))
        try await sut.send(text: requestFormat)
        try await Task.sleep(for: .seconds(10))
    }
    
    func testUserClose() async throws {
        let sut = WebSocketClient(url: URL(string: "wss://echo.websocket.org")!)
        
        await sut.connect()
        
        try await Task.sleep(for: .seconds(2))
        sut.cancel()
        try await Task.sleep(for: .seconds(2))
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
}

