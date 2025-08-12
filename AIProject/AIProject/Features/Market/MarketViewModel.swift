//
//  MarketViewModel.swift
//  AIProject
//
//  Created by kangho lee on 8/7/25.
//

import Foundation

enum MarketCoinTab: Int {
    case bookmark
    case total
}

@Observable
class MarketViewModel {
    private let upbitService: UpBitAPIService
    let coinListViewModel: CoinListViewModel
    
    private(set) var bookmaredCoins: [CoinListModel] = []
    private(set) var totalCoins: [CoinListModel] = []
    
    init(upbitService: UpBitAPIService, coinListViewModel: CoinListViewModel) {
        self.upbitService = upbitService
        self.coinListViewModel = coinListViewModel
        
        Task {
            await setup()
            change(tab: .total)
        }
    }
    
    func change(tab: MarketCoinTab) {
        switch tab {
        case .bookmark:
            coinListViewModel.change(bookmaredCoins)
        case .total:
            coinListViewModel.change(totalCoins)
        }
    }
    
    func refresh() async {
        await setup()
    }
    
    // TODO: Bookmark가 변경된 걸 notify 받고, 변경 해주어야 함
    private func setup() async {
        let coins = await fetchMarketCoinData()
        let bookmaredCoinID = await fetchBookmarkCoin()
        
        self.bookmaredCoins = coins.filter { bookmaredCoinID.contains($0.coinID) }
        self.totalCoins = coins
    }
    
    // TODO: 실제 BookMark Coin 가져오기
    private func fetchBookmarkCoin() async -> Set<CoinListModel.ID> {
        return []
    }
    
    private func fetchMarketCoinData() async -> [CoinListModel] {
        do {
            async let coins = try await upbitService.fetchMarkets()
            async let tickers = try await upbitService.fetchTicker(by: "KRW")
            
            let result = try await coins.reduce(into: [String: (korean: String, english: String)]()) { acc, coins in
                acc[coins.coinID] = (coins.koreanName, coins.englishName)
            }
            return try await tickers.compactMap { ticker in
                CoinListModel(
                    coinID: ticker.coinID,
                    image: "",
                    name: result[ticker.coinID]?.korean ?? "없음",
                    currentPrice: ticker.tradePrice,
                    changePrice: ticker.changeRate,
                    tradeAmount: ticker.accTradePrice
                )
            }
        } catch {
            print(error)
            return []
        }
    }
}
