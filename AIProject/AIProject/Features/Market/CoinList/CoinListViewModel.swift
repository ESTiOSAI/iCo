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
    private let tickerService: UpbitTickerService
    private let coinGeckoService: CoinGeckoAPIService
    
    private let ticket = UUID().uuidString
    
    @ObservationIgnored
    private var visibleCoinsChannel = AsyncChannel<Set<CoinListModel.ID>>()
    
    private(set) var coins: [CoinListModel] = []
    
    init(tickerService: UpbitTickerService, coinGeckoService: CoinGeckoAPIService) {
        self.tickerService = tickerService
        self.coinGeckoService = coinGeckoService
    }
    
    /// 북마크와 전체 코인 리스트를 변경합니다.
    /// - Parameter coins: 보여줄 코인 리스트
    func change(_ coins: [CoinListModel]) {
        self.coins = coins
    }
    
    /// 시세가 서비스에 연결합니다.
    func connect() async {
        
        // coin snapshot 채널 개설
        visibleCoinsChannel = .init()
        
        // coin snapshot 전송 stream 연결
        Task {
            await self.ticketStream()
        }
        
        // service 연결
        await tickerService.connect()
        
        // 시세가
        Task {
            await consume()
        }
    }
    
    /// 서비스 연결 해제
    ///  coin snapshot 채널 종료
    func disconnect() async {
        visibleCoinsChannel.finish()
        await tickerService.disconnect()
    }
    
    /// coin snapshot 구독 전송
    /// - Parameter coins: coin snapshot
    func sendTicket(_ coins: Set<CoinListModel.ID>) async {
        await visibleCoinsChannel.send(coins)
    }
    
    // MARK: - Private
    
    private func fetchImage(_ symbols: Set<CoinListModel.ID>) async {
        let imageMap = await coinGeckoService.fetchImageMapBatched(symbols: Array(symbols))
        await updateImageCoinList(imageMap)
    }
    
    private func ticketStream() async {
        let stream = visibleCoinsChannel
            .filter { !$0.isEmpty }
            .removeDuplicates()
            ._throttle(for: .milliseconds(300), latest: true)
        for await visibleCoin in stream {
            await self.fetchImage(visibleCoin)
            await tickerService.sendTicket(ticket: ticket, coins: Array(visibleCoin))
        }
    }
    
    @MainActor
    private func performUpdate(_ ticker: RealTimeTickerDTO) async {
        guard let index = coins.firstIndex(where: {
            $0.coinID == ticker.coinID
        }) else {
            return
        }
        
        coins[index] = CoinListModel(coinID: ticker.coinID, image: "", name: coins[index].name, currentPrice: ticker.tradePrice, changePrice: ticker.changeRate, tradeAmount: coins[index].tradeAmount, change: .init(rawValue: ticker.change))
    }
    
    private func consume() async {
        for try await ticker in tickerService.subscribeTickerStream() {
            await performUpdate(ticker)
        }
    }
    
    @MainActor
    private func updateImageCoinList(_ imageMap: [String: URL]) {
        imageMap.forEach { key, url in
            guard let index = coins.firstIndex (where: {
                $0.coinName == key
            }) else { return }
            var model = coins[index]
            model.image = url.absoluteString
            coins[index] = model
        }
    }
}
