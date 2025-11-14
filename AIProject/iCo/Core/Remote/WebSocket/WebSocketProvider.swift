//
//  SocketEngine.swift
//  AIProject
//
//  Created by kangho lee on 8/17/25.
//

import Foundation
import AsyncAlgorithms

public protocol WebSocketProvider {
    var stateBroadCaster: AsyncStreamBroadcaster<WebSocket.State> { get }
    var incomingChannel: AsyncChannel<URLSessionWebSocketTask.Message> { get }
    
    /// 웹소켓 세션을 연결하고 작업을 생성합니다.
    func connect() async
    
    /// 명시적으로 현재 WebSocket 연결을 정상적으로 종료합니다.
    ///
    /// 이 메서드는 서버와의 WebSocket 연결을 `normalClosure` 코드로 닫습니다.
    func disconnect() async
    
    /// 텍스트 형태의 메시지를 WebSocket 서버로 전송합니다.
    func send(text: String) async throws
    
    /// 바이너리(Data) 형태의 메시지를 WebSocket 서버로 전송합니다.
    func send(data: Data) async throws
}

public protocol URLSessionType {
    func makeWebSocketTask(with url: URL) -> WebSocketType
}

extension URLSession: URLSessionType {
    public func makeWebSocketTask(with url: URL) -> any WebSocketType {
        return webSocketTask(with: url)
    }
}

public protocol WebSocketType {
    var delegate: (any URLSessionTaskDelegate)? { get set }
    var state: URLSessionTask.State { get }
    
    func resume()
    func cancel(with closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?)
    func send(_ message: URLSessionWebSocketTask.Message) async throws
    func cancel()
    func sendPing(pongReceiveHandler: @escaping @Sendable((any Error)?) -> Void)
    func receive() async throws -> URLSessionWebSocketTask.Message
}

extension URLSessionWebSocketTask: WebSocketType {}

public enum WebSocket {
    public enum State: Sendable {
        case connecting, connected
        case closed
        case reconnecting
    }
}

extension WebSocket.State: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case (.connecting, .connecting):
            return true
        case (.connected, .connected):
            return true
        case (.closed, .closed):
            return true
        case (.reconnecting, .reconnecting):
            return true
        default:
            return false
        }
    }
}
