//
//  RealTimeTickerProvider.swift
//  AIProject
//
//  Created by kangho lee on 8/19/25.
//

import Foundation

protocol RealTimeTickerProvider {
    func connect() async
    func disconnect() async
    func subscribeTickerStream() -> AsyncStream<TickerValue>
    func subscribeStateStream() -> AsyncStream<WebSocket.State>
    func sendTicket(ticket: String, coins: [CoinListModel.ID]) async
}
