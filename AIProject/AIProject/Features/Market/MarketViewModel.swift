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
    private let coinService: UpBitAPIService
    private let imageService: CoinGeckoAPIService
    
    private var hasLoaded = false
    
    private(set) var bookmaredCoins: [CoinListModel] = []
    private(set) var totalCoins: [CoinListModel] = []
    
    init(coinService: UpBitAPIService, imageService: CoinGeckoAPIService) {
        self.coinService = coinService
        self.imageService = imageService
    }
    
    func load() async {
        guard hasLoaded == false else { return }
        defer { hasLoaded = true }
        await setup()
    }
    
    func refresh() async {
        await setup()
    }
    
    // TODO: Bookmark가 변경된 걸 notify 받고, 변경 해주어야 함
    private func setup() async {
        let coins = await fetchMarketCoinData()
        let bookmaredCoinID = await fetchBookmarkCoin()
        
        let coinSymbols = Array(coins.map(\.coinName.localizedLowercase).prefix(100))
        let imageMap = await imageService.fetchImageMapByEnglishNames(englishNames: coinSymbols)
        
        let imageCoins = coins.map { meta in
            var mutable = meta
            mutable.image = imageMap[meta.coinName]?.absoluteString ?? ""
            return mutable
        }
        
        self.bookmaredCoins = imageCoins.filter { bookmaredCoinID.contains($0.coinID) }
        self.totalCoins = imageCoins
    }
    
    // TODO: 실제 BookMark Coin 가져오기
    private func fetchBookmarkCoin() async -> Set<CoinListModel.ID> {
        return Set( (try? BookmarkManager.shared.fetchAll().map(\.coinID)) ?? [])
    }
    
    private func fetchMarketCoinData() async -> [CoinListModel] {
        do {
            async let coins = try await coinService.fetchMarkets()
            async let tickers = try await coinService.fetchTicker(by: "KRW")
            
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
