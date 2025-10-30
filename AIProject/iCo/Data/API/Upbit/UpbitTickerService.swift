//
//  UpbitTickerService.swift
//  AIProject
//
//  Created by kangho lee on 8/10/25.
//

import Foundation

/// 업비트 실시간 코인 시세 웹소켓 서비스
final class UpbitTickerService: RealTimeTickerProvider {
    private let client: WebSocketClient
    
    /// 소켓 상태 stream
    private var stateStreamTask: Task<Void, Never>?
    
    init(client: WebSocketClient = WebSocketClient(url: URL(string: "wss://api.upbit.com/websocket/v1")!)) {
        self.client = client
    }
    
    func connect() async {
        await client.connect()
    }
    
    func disconnect() async {
        await client.disconnect()
    }
    
    /// 업비트의 코인 시세 stream을 가져와 디코딩하여 Model로 만들고 forwarding
    /// - Returns: 시세 스트림을 반환
    func subscribeTickerStream() -> AsyncStream<TickerValue> {
        AsyncStream<TickerValue> { continuation in
            Task {
                for await message in client.incomingChannel {
                    switch message {
                    case .data(let data):
                        if let ticker = mapTicker(data) {
                            continuation.yield(ticker)
                        }
                    case .string(let string):
                        print(string)
                    }
                }
                
                continuation.finish()
            }
        }
    }
    
    func subscribeStateStream() -> AsyncStream<WebSocket.State> {
        client.stateBroadCaster.stream()
    }
    
    /// 티켓과 코인 ID를 가지고 업비트에 코인 시세를 구독합니다.
    /// - Parameters:
    ///   - ticket: 티켓 iD
    ///   - coins: 코인 ID 리스트 -[ "KRW-BTC", "KRW-ETH"]
    func sendTicket(ticket: String, coins: [CoinListModel.ID]) async {
        guard !coins.isEmpty else { return }
        
        do {
            let ticketData = try JSONEncoder().encode(SubscribeRequest.ticker(ticket: ticket, codes: coins))
            try await client.send(data: ticketData)
        } catch {
            debugPrint(error)
        }
    }
    
    private func mapTicker(_ data: Data) -> TickerValue? {
        do {
            let ticker = try JSONDecoder().decode(RealTimeTickerDTO.self, from: data)
            return TickerValue(id: ticker.coinID, price: ticker.tradePrice, volume: ticker.volume, rate: ticker.changeRate, change: .init(rawValue: ticker.change))
        } catch {
            if let stringData = String(data: data, encoding: .utf8) {
                debugPrint(stringData)
            } else {
                debugPrint(error)
            }
            return nil
        }
    }
}

