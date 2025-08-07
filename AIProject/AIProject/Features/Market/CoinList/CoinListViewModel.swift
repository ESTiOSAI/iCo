//
//  CoinListViewModel.swift
//  AIProject
//
//  Created by kangho lee on 8/4/25.
//

import Foundation
import AsyncAlgorithms

@Observable
class CoinListViewModel {
    private let socket: WebSocketClient
    private let upbitService: UpBitAPIService
    private let ticket = UUID().uuidString
    
    @ObservationIgnored
    private let visibleCoinsChannel = AsyncChannel<Set<CoinListModel.ID>>()
    
    private(set) var coins: [CoinListModel] = []
    
    init(socket: WebSocketClient, upbitService: UpBitAPIService = UpBitAPIService()) {
        self.socket = socket
        self.upbitService = upbitService
        
        Task {
            await fetchInitial()
            await ticketStream()
        }
    }
    
    // MARK: - Private
    
    private func fetchInitial() async {
        self.coins = await fetchMarketCoinData()
    }
    
    private func ticketStream() async {
        let stream = visibleCoinsChannel
            .removeDuplicates()
            ._throttle(for: .milliseconds(500), latest: true)
        for await visibleCoin in stream {
            await socket.subscribe(ticket: ticket, coins: Array(visibleCoin))
        }
    }
    
    private func performUpdate(_ ticker: RealTimeTickerDTO) async {
        guard let index = coins.firstIndex(where: {
            $0.coinID == ticker.coinID
        }) else {
            return
        }
        
        coins[index] = CoinListModel(coinID: ticker.coinID, image: "", name: coins[index].name, currentPrice: ticker.tradePrice, changePrice: ticker.changeRate, tradeAmount: coins[index].tradeAmount, change: .init(rawValue: ticker.change))
    }
    
    private func consume() async {
        guard let stream = socket.subscribe() else {
            return
        }
        do {
            for try await ticker in stream {
                await performUpdate(ticker)
            }
        } catch {
            socket.disconnect()
        }
    }
    
    private func fetchMarketCoinData() async -> [CoinListModel] {
        async let coins = (try? await upbitService.fetchMarkets()) ?? []
        async let tickers = (try? await upbitService.fetchTicker(by: "KRW")) ?? []
        
        let result = await coins.reduce(into: [String: (korean: String, english: String)]()) { acc, coins in
            acc[coins.coinID] = (coins.koreanName, coins.englishName)
        }
        
        return await tickers.compactMap { ticker in
            CoinListModel(
                coinID: ticker.coinID,
                image: "",
                name: result[ticker.coinID]?.korean ?? "없음",
                currentPrice: ticker.tradePrice,
                changePrice: ticker.changeRate,
                tradeAmount: ticker.accTradePrice
            )
        }
    }
    
    // TODO: error handling
    func connect() async {
        do {
            try await socket.connect()
            await consume()
        } catch {
            print(error)
        }
    }
    
    func disconnect() {
        socket.disconnect()
    }
    
    func sendTIcket(_ coins: Set<CoinListModel.ID>) async {
        await visibleCoinsChannel.send(coins)
    }
}
