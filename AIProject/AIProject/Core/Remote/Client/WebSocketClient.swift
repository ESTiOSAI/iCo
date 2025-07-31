//
//  WebSocketClient.swift
//  AIProject
//
//  Created by 강대훈 on 7/30/25.
//

import Foundation

final class WebSocketClient: NSObject {
    private let endpoint = "wss://api.upbit.com/websocket/v1"
    /// URLSession 웹소켓 태스크
    private var webSocketTask: URLSessionWebSocketTask?
    /// 소켓 연결 상태 확인
    private var isActive = false

    /// 비동기 스트림 방식의 데이터 방출
    typealias WebSocketStream = AsyncThrowingStream<CoinDTO, Error>
    private var continuation: WebSocketStream.Continuation?

    /// 비동기 데이터를 방출할 스트림
    private var stream: WebSocketStream?
    /// 지속적으로 서버에 핑을 보내기 위한 타이머
    private var timer: Timer?

    /// 웹소켓 연결을 시작합니다.
    func connect() async throws {
        let session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)

        guard let url = URL(string: endpoint) else { throw NetworkError.invalidURL }
        self.webSocketTask = session.webSocketTask(with: url)  // (웹소켓) 작업 저장

        self.webSocketTask?.resume()

        checkingAlive()
        await sendPing()
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

    /// 비동기 스트림 방식의 메소드
    private func receiveMessageByStream() async throws {
        isActive = true // 스트림 활성화

        stream = WebSocketStream { continuation in
            self.continuation = continuation
        }

        while isActive && webSocketTask?.closeCode == .invalid {
            do {
                let message = try await webSocketTask?.receive()

                switch message {
                case .data(let data):
                    do {
                        let coinData = try JSONDecoder().decode(CoinDTO.self, from: data)
                        continuation?.yield(coinData) // 코인 데이터 방출
                    } catch {
                        throw NetworkError.webSocketError
                    }
                default:
                    throw NetworkError.webSocketError
                }
            } catch {
                continuation?.yield(with: .failure(NetworkError.webSocketError))
                disconnect()
            }
        }

        stream = nil
        continuation?.finish()
    }

    /// 초마다 핑 보내는 메소드
    private func checkingAlive() {
        timer = Timer.scheduledTimer(withTimeInterval: 20, repeats: true, block: { [weak self] _ in
            guard let self else { return }
            Task {
                await self.sendPing()
            }
        })
    }

    /// 요청 포맷
    private func sendPing() async {
        /// 요청 JSON 포맷
        /// 현재 예제는 비트코인, 이더리움, 리플을 반환함.
        // TODO: 강호님과 얘기 후에 수정 예정
        let requestFormat = "[{ticket:test},{type:ticker,codes:[KRW-BTC, KRW-ETH, KRW-XRP]}]"

        do {
            try await webSocketTask?.send(URLSessionWebSocketTask.Message.string(requestFormat))
        } catch {
            print(error.localizedDescription)
        }
    }

    deinit {
        self.disconnect()
    }
}

extension WebSocketClient: URLSessionWebSocketDelegate {
    /// 웹 소켓 연결 시작
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        Task {
            try await self.receiveMessageByStream() /// 소켓 데이터 수신 시작
        }
    }

    /// 웹 소켓 연결 종료
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        disconnect()
    }
}
