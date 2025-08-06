//
//  CoinListViewModel.swift
//  AIProject
//
//  Created by kangho lee on 8/4/25.
//

import Foundation

@Observable
class CoinListViewModel {
    private let socket: WebSocketClient
    private let upbitService: UpBitAPIService
    private let ticket = UUID().uuidString
    
    var coins: [CoinListModel] = []
    
    init(socket: WebSocketClient) {
        self.socket = socket
        self.upbitService = UpBitAPIService()
        
        Task {
            await fetchInitial()
        }
    }
    
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
    
    func fetchInitial() async {
        self.coins = await fetchMarketCoinData()
    }
    
    func sendTIcket(_ coins: Set<CoinListModel.ID>) async {
        await socket.subscribe(ticket: ticket, coins: Array(coins))
    }
    
    func consume() async {
//        guard let stream = socket.subscribe() else { return }
        guard let stream = socket.subscribe() else {
            print("stream 생성되지 않음")
            return
        }
        do {
            print("stream 생성됨")
            for try await ticker in stream {
                guard let index = coins.firstIndex(where: {
                    $0.coinID == ticker.coinID
                }) else {
                    return
                }
                
                coins[index] = CoinListModel(coinID: ticker.coinID, image: "", name: coins[index].coinName, currentPrice: ticker.tradePrice, changePrice: ticker.changeRate, tradeAmount: coins[index].tradeAmount, change: .init(rawValue: ticker.change))
                
                print(coins[index])
            }
        } catch {
            print(error)
            print("에러 발생")
        }
    }
    
    func unsubscribe(_ coins: Set<CoinListModel.ID>) async {
        await socket.subscribe(ticket: ticket, coins: Array(coins))
        await consume()
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
}
