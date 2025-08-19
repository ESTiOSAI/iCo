//
//  UpbitTickerService.swift
//  AIProject
//
//  Created by kangho lee on 8/10/25.
//

import Foundation

final class UpbitTickerService {
    private let client: any SocketEngine
    
    init(client: any SocketEngine = ReconnectableWebSocketClient {
        BaseWebSocketClient(url: URL(string: "wss://api.upbit.com/websocket/v1")!)
    }) {
        self.client = client
    }
    
    func connect() async {
        await client.connect()
    }
    
    func disconnect() async {
        await client.close()
    }
    
    func subscribeTickerStream() -> AsyncStream<TickerValue> {
        AsyncStream<TickerValue> { continuation in
            Task {
                for await message in client.incoming {
                    switch message {
                    case .success(let data):
                        if let ticker = mapTicker(data) {
                            continuation.yield(ticker)
                        }
                    case .failure(let error):
                        debugPrint(error)
                    }
                }
                continuation.finish()
            }
        }
    }
    
    func sendTicket(ticket: String, coins: [CoinListModel.ID]) async {
        guard !coins.isEmpty else { return }
        
        do {
            let ticketData = try JSONEncoder().encode(SubscribeRequest.ticker(ticket: ticket, codes: coins))
            try await client.send(ticketData)
        } catch {
            debugPrint(error)
        }
    }
    
    private func mapTicker(_ data: Data) -> TickerValue? {
        do {
            // TODO: 거래대금 집언허기
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
