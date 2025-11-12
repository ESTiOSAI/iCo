//
//  MockURLSession.swift
//  iCoTests
//
//  Created by 강대훈 on 11/12/25.
//

import Foundation
@testable import iCo

final class MockURLSession: URLSessionType {
    let task: MockWebSocketTask
    
    init(task: MockWebSocketTask) {
        self.task = task
    }
    
    func makeWebSocketTask(with url: URL) -> WebSocketType {
        return task
    }
}
