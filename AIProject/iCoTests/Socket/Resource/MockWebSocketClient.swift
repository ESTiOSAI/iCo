//
//  MockWebSocketClient.swift
//  iCo
//
//  Created by 강대훈 on 11/12/25.
//

@testable import iCo

final class MockWebSocketClient: WebSocketClient {
    func disconnectWithCloseCode() async { // 의도적인 에러
        task?.cancel(with: .internalServerError, reason: nil)
    }
    
    func disconnectWithoutCloseCode() async {
        task?.cancel()
    }
}
