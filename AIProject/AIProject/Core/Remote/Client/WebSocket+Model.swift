//
//  WebSocket+Model.swift
//  AIProject
//
//  Created by kangho lee on 8/10/25.
//

import Foundation

enum WebSocket {
    struct ErrorResponse: Decodable {
        struct Message: Decodable {
            let message: String
            let name: String
        }
        
        let error: Message
    }
}

extension WebSocketClient2 {
    enum EndPoint {
        case upbit
        
        var url: URL {
            switch self {
            case .upbit:
                return URL(string: "wss://api.upbit.com/websocket/v1")!
            }
        }
    }
    
    typealias WebSocketStream = AsyncThrowingStream<URLSessionWebSocketTask.Message, Error>
    
    enum State {
        case notConnected
        case connecting
        case connected
        case disconnected
    }
    
    enum Event {
        case connecting
        case connected
        case disconnected(code: URLSessionWebSocketTask.CloseCode, reason: String)
        case error(String, Error)
        case complete(Error?)
    }
    
    enum SocketError: Error {
        case alreadyConnected
        case notConnected
        case pingError(Error)
    }
}
