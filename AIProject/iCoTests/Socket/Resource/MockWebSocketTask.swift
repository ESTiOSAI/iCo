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
            taskState = .running
            delegate.urlSession?(fakeSession, webSocketTask: fakeTask, didOpenWithProtocol: nil)
        }
    }
    
    func cancel(with closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        cancelCallCount += 1
        closed = true
        taskState = .canceling
        
        if let delegate = delegate as? URLSessionWebSocketDelegate {
            delegate.urlSession?(fakeSession, webSocketTask: fakeTask, didCloseWith: closeCode, reason: nil)
            delegate.urlSession?(fakeSession, task: fakeTask, didCompleteWithError: nil)
        }
        
        taskState = .completed
    }
    
    func cancel() {
        cancelCallCount += 1
        closed = true
        taskState = .completed
        
        let error = URLError(.notConnectedToInternet)
        delegate?.urlSession?(fakeSession, task: fakeTask, didCompleteWithError: error)
    }
    
    func send(_ message: URLSessionWebSocketTask.Message) async throws {
        if throwError {
            taskState = .completed
            throw NSError(
                domain: NSURLErrorDomain,
                code: -1009,
                userInfo: [NSLocalizedDescriptionKey: "인터넷 에러 코드 -1009"]
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
                userInfo: [NSLocalizedDescriptionKey: "인터넷 에러 코드 -1009"]
            ))
        } else {
            pongReceiveHandler(nil)
            sendPingCallCount += 1
        }
    }
    
    func receive() async throws -> URLSessionWebSocketTask.Message {
        if closed {
            throw NSError(
                domain: NSURLErrorDomain,
                code: URLError.cancelled.rawValue,
                userInfo: nil
            )
        }
        
        receiveCallCount += 1
        return .string("데이터 잘 받았습니다.")
    }
    
    func disconnect(with code: URLSessionWebSocketTask.CloseCode? = nil) {
        if let code {
            self.cancel(with: code, reason: nil)
        } else {
            self.cancel()
        }
    }
}
