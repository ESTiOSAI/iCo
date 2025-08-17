//
//  UpbitTickerService.swift
//  AIProject
//
//  Created by kangho lee on 8/10/25.
//

import Foundation

final class UpbitTickerService {
    private let client: WebSocketClient
    
    init(client: WebSocketClient = .init(pingInterval: .seconds(120))) {
        self.client = client
    }
    
    func connect() async {
        await client.connect()
    }
    
    func disconnect() async {
        await client.disconnect(closeCode: .normalClosure, reason: nil)
    }
    
    func subscribeTickerStream() -> AsyncStream<RealTimeTickerDTO> {
        AsyncStream<RealTimeTickerDTO> { continuation in
            Task {
                for await message in await client.stream() {
                    switch message {
                    case .data(let data):
                        if let ticker = mapTicker(data) {
                            continuation.yield(ticker)
                        }
                    case .string(let string):
                        debugPrint(string)
                    @unknown default:
                        debugPrint("unknown messages")
                    }
                }
                continuation.finish()
            }
        }
    }
    
    func sendTicket(ticket: String, coins: [CoinListModel.ID]) async {
        guard !coins.isEmpty else { return }
        
        do {
            let ticketData = try JSONEncoder().encode(SubscribeRequest.ticker(ticket: ticket, codes: coins).components())
            try await client.send(data: ticketData)
        } catch {
            debugPrint(error)
        }
    }
    
    private func mapTicker(_ data: Data) -> RealTimeTickerDTO? {
        do {
            let ticker = try JSONDecoder().decode(RealTimeTickerDTO.self, from: data)
            return ticker
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
