//
//  SocketEngine.swift
//  AIProject
//
//  Created by kangho lee on 8/17/25.
//

import Foundation

public protocol SocketEngine {
    var state: AsyncStream<WebSocket.State> { get }
    var incoming: AsyncStream<Result<Data, WebSocket.MessageFailure>> { get }
    func connect() async
    func send(_ data: Data) async throws
    func close() async
}

public enum WebSocket {
    public enum State: Sendable {
        case connecting, connected
        case failed(Error)
        case closed(code: URLSessionWebSocketTask.CloseCode, reason: Data?)
        case reconnecting(nextAttempsIn: Duration)
    }
    
    public enum Failure: Error {
        
        /// 네트워크 끊김, timeout
        case retryable(underlying: Error?)
        
        /// 인증/정책/프로토콜 위반
        case nonRetryable(underlying: Error?)
        case closed(code: URLSessionWebSocketTask.CloseCode, reason: Data?)
    }
    
    public enum MessageFailure: Error {
        case frameCorrupted
        case failed(Error)
    }
    
    public enum RetryFailure: Error {
        case exceedAttemps
    }
}

extension WebSocket.State: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case (.connecting, .connecting):
            return true
        case (.connected, .connected):
            return true
        case (.failed(let lhsError), .failed(let rhsError)):
            return lhsError as NSError == rhsError as NSError
        case (.closed(let lhsCode, let lhsReason), .closed(let rhsCode, let rhsReason)):
            return lhsCode == rhsCode && lhsReason == rhsReason
        case (.reconnecting(let lhsDelay), .reconnecting(let rhsDelay)):
            return lhsDelay == rhsDelay
        default:
            return false
        }
    }
}
