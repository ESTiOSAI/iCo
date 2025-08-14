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
    private var lastTicketCoins: Set<CoinListModel.ID> = []
    
    private let ticket = UUID().uuidString
    
    private(set) var tickerCoins: [CoinListModel] = []
    
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
        self.tickerCoins = coins
    }
    
    /// 시세가 서비스에 연결합니다.
    func connect() async {
        
        // coin snapshot 채널 개설
        visibleCoinsChannel = .init()
        
        // coin snapshot 전송 stream 연결
        
        // service 연결
        await tickerService.connect()
        
        Task {
            await self.ticketStream()
        }
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
    
    private func ticketStream() async {
        let stream = visibleCoinsChannel
            .filter { !$0.isEmpty }
            .removeDuplicates()
            ._throttle(for: .milliseconds(300), latest: true)
        for await visibleCoin in stream {
            debugPrint("send Ticket")
            lastTicketCoins = visibleCoin
            await tickerService.sendTicket(ticket: ticket, coins: Array(visibleCoin))
        }
    }
    
    private func performUpdate(_ ticker: RealTimeTickerDTO) async {
        guard let index = tickerCoins.firstIndex(where: {
            $0.coinID == ticker.coinID
        }) else {
            return
        }
        
        let updated = CoinListModel(coinID: ticker.coinID, image: tickerCoins[index].image, name: tickerCoins[index].name, currentPrice: ticker.tradePrice, changePrice: ticker.changeRate, tradeAmount: tickerCoins[index].tradeAmount, change: .init(rawValue: ticker.change))
        
        var copy = tickerCoins
        copy[index] = updated
        tickerCoins = copy
    }
    
    private func consume() async {
        for try await ticker in tickerService.subscribeTickerStream() {
            await performUpdate(ticker)
        }
    }
}
