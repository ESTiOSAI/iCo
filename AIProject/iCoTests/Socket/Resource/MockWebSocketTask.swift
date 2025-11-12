//
//  MockWebSocketTask.swift
//  iCo
//
//  Created by 강대훈 on 11/12/25.
//

import Foundation
@testable import iCo

final class MockWebSocketTask: WebSocketType {
    var delegate: URLSessionTaskDelegate?
    
    private var closed: Bool = false
    private var taskState: URLSessionTask.State = .completed
    private var fakeSession: URLSession = URLSession(configuration: .ephemeral)
    private var fakeTask: URLSessionWebSocketTask {
        fakeSession.webSocketTask(with: URL(string: "wss://")!)
    }
    
    var state: URLSessionTask.State {
        return taskState
    }
    
    private var throwError: Bool
    
    var messages: [URLSessionWebSocketTask.Message] = []
    
    var resumeCallCount: Int = 0
    var cancelCallCount: Int = 0
    var sendCallCount: Int = 0
    var sendPingCallCount: Int = 0
    var receiveCallCount: Int = 0
    
    init(throwError: Bool = false) {
        self.throwError = throwError
    }
    
    func resume() {
        resumeCallCount += 1
        
        if let delegate = delegate as? URLSessionWebSocketDelegate {
            delegate.urlSession?(fakeSession, webSocketTask: fakeTask, didOpenWithProtocol: nil)
            taskState = .running
        }
    }
    
    func cancel(with closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        cancelCallCount += 1
        taskState = .canceling
        closed = true
        
        if let delegate = delegate as? URLSessionWebSocketDelegate {
            delegate.urlSession?(fakeSession, webSocketTask: fakeTask, didCloseWith: closeCode, reason: nil)
            delegate.urlSession?(fakeSession, task: fakeTask, didCompleteWithError: nil)
        }
    }
    
    func cancel() {
        cancelCallCount += 1
        taskState = .canceling
        closed = true
        
        let error = URLError(.notConnectedToInternet)
        delegate?.urlSession?(fakeSession, task: fakeTask, didCompleteWithError: error)
    }
    
    func send(_ message: URLSessionWebSocketTask.Message) async throws {
        if throwError {
            throw NSError(
                domain: NSURLErrorDomain,
                code: -1009,
                userInfo: [NSLocalizedDescriptionKey: "The Internet connection appears to be offline."]
            )
        }
        
        messages.append(message)
        sendCallCount += 1
    }
    
    func sendPing(pongReceiveHandler: @escaping ((any Error)?) -> Void) {
        if throwError || state != .running {
            pongReceiveHandler(NSError(
                domain: NSURLErrorDomain,
                code: -1009,
                userInfo: [NSLocalizedDescriptionKey: "The Internet connection appears to be offline."]
            ))
            return
        } else {
            pongReceiveHandler(nil)
            sendPingCallCount += 1
        }
    }
    
    func receive() async throws -> URLSessionWebSocketTask.Message {
        if closed { // 작업이 종료되었을 때 에러 던져야 함.
            throw NSError(
                domain: NSURLErrorDomain,
                code: URLError.cancelled.rawValue,
                userInfo: nil
            )
        }
        
        receiveCallCount += 1
        return .string("데이터 잘 받았습니다.")
    }
    
    func disconnect(with code: URLSessionWebSocketTask.CloseCode?) {
        if let code {
            self.cancel(with: code, reason: nil)
        } else {
            self.cancel()
        }
    }
}
