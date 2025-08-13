//
//  WebSocketClient.swift
//  AIProject
//
//  Created by 강대훈 on 7/30/25.
//

import Foundation

/// 웹소켓 통신을 담당하는 객체
final class WebSocketClient: NSObject {
    private let endpoint = "wss://api.upbit.com/websocket/v1"
    
    /// URLSession 웹소켓 태스크
    private var webSocketTask: URLSessionWebSocketTask?
    
    /// 소켓 연결 상태 확인
    private var isActive = false
    
    /// 비동기 스트림 방식의 데이터 방출
    typealias WebSocketStream = AsyncThrowingStream<RealTimeTickerDTO, Error>
    private var continuation: WebSocketStream.Continuation?
    
    /// 비동기 데이터를 방출할 스트림
    private var stream: WebSocketStream?
    
    /// 지속적으로 서버에 핑을 보내기 위한 타이머
    private var timer: Timer?
    
    override init() {
        super.init()
        
        print(#function, #file)
    }
    
    /// 웹소켓 연결을 시작합니다.
    func connect() async throws {
        disconnect()
        
        guard let url = URL(string: endpoint) else { throw NetworkError.invalidURL }
        
        let session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
        self.webSocketTask = session.webSocketTask(with: url)  // (웹소켓) 작업 저장
        self.webSocketTask?.resume()
        
        checkingAlive()
        try await sendPing()
    }
    
    /// 웹소켓 연결을 종료합니다.
    func disconnect() {
        // 웹소켓 종료
        webSocketTask?.cancel(with: .goingAway, reason: nil)
        webSocketTask = nil
        
        // 타이머 종료
        timer?.invalidate()
        timer = nil
        
        isActive = false
    }
    
    /// 데이터를 방출하는 스트림을 반환합니다.
    func subscribe() -> WebSocketStream? {
        return stream
    }
    
    /// 코인 시세 요청 전송
    /// - Parameters:
    ///   - ticket: 고유한 ID를 가진 티켓
    ///   - coins: 코인ID 예시: KRW-BTC
    func subscribe(ticket: String, coins: [String]) async {
        guard !coins.isEmpty else { return }
        /// 요청 JSON 포맷
        let jsonData: [[String: Any]] = [
            ["ticket": ticket],
            ["type": "ticker", "codes": coins]
        ]
        
        if let requestData = try? JSONSerialization.data(withJSONObject: jsonData) {
            try? await self.webSocketTask?.send(.data(requestData))
        }
    }
    
    /// 비동기 스트림 방식의 메소드
    private func receiveMessageByStream() async throws {
        isActive = true // 스트림 활성화
        
        stream = WebSocketStream { continuation in
            self.continuation = continuation
        }
        print("stream 체결 됨")
        defer {
            continuation?.finish()
            stream = nil
            print("continuation 초기화")
        }
        
        while isActive && webSocketTask?.closeCode == .invalid {
            do {
                let message = try await webSocketTask?.receive()
                
                switch message {
                case .data(let data):
                    do {
                        let coinData = try JSONDecoder().decode(RealTimeTickerDTO.self, from: data)
                        continuation?.yield(coinData) // 코인 데이터 방출
                    } catch {
                        if let response = try? JSONDecoder().decode(WebSocket.ErrorResponse.self, from: data) {
                            print(#line, response.error.message)
                        } else {
                            let result = String(data: data, encoding: .utf8) ?? error.localizedDescription
                            print(#line, result)
                        }
                    }
                default: print("text")
                    
                }
            } catch {
                print(error)
                continuation?.yield(with: .failure(NetworkError.webSocketError))
            }
        }
    }
    
    /// 120초마다 핑 보내는 메소드 - Upbit 기준
    /// 초마다 핑 보내는 메소드
    private func checkingAlive() {
        timer = Timer.scheduledTimer(withTimeInterval: 120, repeats: true, block: { [weak self] _ in
            guard let self else { return }
            Task {
                try? await self.sendPing()
            }
        })
    }
    
    private func sendPing() async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            if let socket = webSocketTask {
                socket.sendPing { error in
                    if let error {
                        continuation.resume(throwing: error)
                        return
                    }
                    continuation.resume()
                }
            } else {
                continuation.resume(throwing: NetworkError.webSocketError)
            }
            
        }
    }
    
    // TODO: Ping 보내는 걸 고려해보기
    private func sendPing2(coins: [String] = ["KRW-NEWT", "KRW-ONDO", "KRW-PENGU", "KRW-STRIKE", "KRW-XLM", "KRW-GAS", "KRW-MNT", "KRW-ENA", "KRW-SOL", "KRW-USDT", "KRW-ETH", "KRW-ERA", "KRW-PROVE", "KRW-XRP", "KRW-DOGE", "KRW-BTC", "KRW-SUI"], ticket: String = "test") async {

        do {
            let jsonData: [[String: Any]] = [
                ["ticket": ticket],
                ["type": "ticker", "codes": coins]
            ]
            
            if let requestData = try? JSONSerialization.data(withJSONObject: jsonData) {
                try await self.webSocketTask?.send(.data(requestData))
            }
            print("핑 성공!")
        } catch {
            print("핑 관련 에러 발생: \(error.localizedDescription)")
        }
    }
    
    deinit {
        self.disconnect()
    }
}

extension WebSocketClient: URLSessionWebSocketDelegate {
    /// 웹 소켓 연결 시작
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        print("DidOpen")
        Task {
            try await self.receiveMessageByStream() /// 소켓 데이터 수신 시작
        }
    }
    
    /// 웹 소켓 연결 종료
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        var r = ""
        if let reason, let string = String(data: reason, encoding: .utf8) {
            r = string
        }
        print("DidClose reason: \(r) code: \(closeCode)")
        disconnect()
    }
}
