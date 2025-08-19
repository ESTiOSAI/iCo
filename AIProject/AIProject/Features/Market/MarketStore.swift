//
//  MarketStore.swift
//  AIProject
//
//  Created by kangho lee on 8/7/25.
//

import Foundation
import AsyncAlgorithms

typealias CoinID = String

enum CoinFilter: Int, Equatable {
    case bookmark
    case none
}

@MainActor
@Observable
class MarketStore {
    private var hasLoaded = false
    private let ticket = UUID().uuidString
    
    private let coinService: UpBitAPIService
    private let tickerService: UpbitTickerService
    
    private(set) var errorMessage: String?
    private(set) var coinMeta: [CoinID: Coin] = [:]
    
    private var ticker: [CoinID: TickerStore] = [:]
    
    private var bookmarkIDs: Set<CoinID> = []
    
    private var ticketStreamTask: Task<Void, Never>?
    private var tickerStreamTask: Task<Void, Never>?
    
    var sortCategory: Market.SortCategory = .volume {
        didSet {
            sort()
        }
    }
    var volumeSortOrder: SortOrder = .descending {
        didSet {
            sort()
        }
    }
    var rateSortOrder: SortOrder = .none {
        didSet {
            sort()
        }
    }
    var filter: CoinFilter = .none {
        didSet {
            sort()
        }
    }

    var sortedCoinIDs: [CoinID] = []
    
    @ObservationIgnored
    private var visibleCoinsChannel = AsyncChannel<Set<CoinListModel.ID>>()
    
    init(coinService: UpBitAPIService, tickerService: UpbitTickerService) {
        self.coinService = coinService
        self.tickerService = tickerService
    }
}

extension MarketStore {
    
    func load() async {
        guard hasLoaded == false else { return }
        defer { hasLoaded = true }
        await setup()
    }
    
    func refresh() async {
        await setup()
    }
    
    func update(_ items: [CoinID]) {
        self.bookmarkIDs = Set(items)
    }
    
    func ticker(for id: CoinID) -> TickerStore? {
        ticker[id]
    }
    
    private func setup() async {
        (coinMeta, ticker) = await fetchMarketCoinData()
        sort()
    }
    
    func sort() {
        let ids: [CoinID]
        switch sortCategory {
        case .rate:
            ids = Array(ticker)
                .sorted {
                    switch rateSortOrder {
                    case .ascending, .none:
                        $0.value.signedRate < $1.value.signedRate
                    case .descending:
                        $0.value.signedRate > $1.value.signedRate
                    }
                }.map(\.key)
        case .volume:
            ids = Array(ticker)
                .sorted {
                    switch volumeSortOrder {
                    case .ascending, .none:
                        $0.value.volume < $1.value.volume
                    case .descending:
                        $0.value.volume > $1.value.volume
                    }
                }.map(\.key)
        }
        
        sortedCoinIDs = ids
    }
    
    private func fetchMarketCoinData() async -> ([CoinID: Coin], [CoinID: TickerStore]) {
        do {
            async let meta = try await coinService.fetchMarkets()
                .reduce(into: [CoinID: Coin]()) { acc, dto in
                    acc[dto.coinID] = Coin(id: dto.coinID, koreanName: dto.koreanName)
                }
            async let tickers: [CoinID: TickerStore] = {
                var acc = [CoinID: TickerStore]()
                for dto in try await coinService.fetchTicker(by: "KRW") {
                    let store = TickerStore(coinID: dto.id)
                    await store.apply(dto)
                    acc[dto.id] = store
                }
                return acc
            }()
            
            return (try await meta, try await tickers)
        } catch {
            errorMessage = error.localizedDescription
            return ([:], [:])
        }
    }
}

// MARK: 

extension MarketStore {
    
    /// 시세가 서비스에 연결합니다.
    func connect() async {
        
        // coin snapshot 채널 개설
        visibleCoinsChannel = .init()
        self.ticketStreamTask?.cancel()
        self.tickerStreamTask?.cancel()
        
        // coin snapshot 전송 stream 연결
        self.ticketStreamTask = Task {
            await ticketStream()
        }
        
        // service 연결
        await tickerService.connect()
        
        // 시세가
        self.tickerStreamTask = Task {
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
            await tickerService.sendTicket(ticket: ticket, coins: Array(visibleCoin))
        }
    }
    
    private func performUpdate(_ ticker: TickerValue) async {
        guard let store = self.ticker[ticker.id] else { return }
        store.apply(ticker)
    }
    
    private func consume() async {
        for try await ticker in tickerService.subscribeTickerStream() {
            await performUpdate(ticker)
        }
    }
}

struct TickerValue: Sendable, Identifiable, CoinSymbolConvertible {
    typealias ChangeType = CoinListModel.TickerChangeType
    let id: String
    let price: Double
    let volume: Double
    let rate: Double
    let change: ChangeType
    
    var coinSymbol: String {
        id.components(separatedBy: "-").last ?? ""
    }
}
