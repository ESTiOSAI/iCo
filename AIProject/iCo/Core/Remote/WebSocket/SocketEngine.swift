//
//  SocketEngine.swift
//  AIProject
//
//  Created by kangho lee on 8/17/25.
//

import Foundation
import AsyncAlgorithms

public protocol SocketEngine {
    var stateChannel: AsyncChannel<WebSocket.State> { get set }
    var incomingChannel: AsyncChannel<Result<Data, WebSocket.MessageFailure>> { get set }
    func connect() async
    func send(_ data: Data) async throws
    func close() async
}

public enum WebSocket {
    public enum State: Sendable {
        case connecting, connected
        case failed
        case closed
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
        case (.reconnecting(let lhsDelay), .reconnecting(let rhsDelay)):
            return lhsDelay == rhsDelay
        default:
            return false
        }
    }
}
