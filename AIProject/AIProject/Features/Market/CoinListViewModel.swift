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
    
    var coins: [CoinListModel] = []
    
    init(socket: WebSocketClient) {
        self.socket = socket
        self.upbitService = UpBitAPIService()
    }
    
    func connect() async {
        try? await socket.connect()
    }
    
    func disconnect() {
        socket.disconnect()
    }
    
    func fetchInitial() async {
        self.coins = await fetchMarketCoinData()
    }
    
    func subscribe(_ coins: Set<CoinListModel.ID>) {
        
    }
    
    func unsubscribe(_ coins: Set<CoinListModel.ID>) {
        
    }
    
    private func fetchMarketCoinData() async -> [CoinListModel] {
        async let coins = (try? await upbitService.fetchMarkets()) ?? []
        async let tickers = (try? await upbitService.fetchTicker(by: "KRW")) ?? []
        
        let result = await coins.reduce(into: [String: (korean: String, english: String)]()){ acc, coins in
                    
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
