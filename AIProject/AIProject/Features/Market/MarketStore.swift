//
//  MarketStore.swift
//  AIProject
//
//  Created by kangho lee on 8/7/25.
//

import Foundation
import AsyncAlgorithms
import WidgetKit

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
    private let tickerService: RealTimeTickerProvider
    private let searchRecordManager: SearchRecordManaging = SearchRecordManager()
    
    private(set) var errorMessage: String?
    private(set) var coinMeta: [CoinID: Coin] = [:]
    
    private var ticker: [CoinID: TickerStore] = [:]
    
    private var ticketStreamTask: Task<Void, Never>?
    private var tickerStreamTask: Task<Void, Never>?
    
    private var bookmarkIDs: Set<CoinID> = [] {
        didSet {
            Task {
                await sortChannel.send(())
            }
        }
    }
    
    private var searchText: String = "" {
        didSet {
            Task {
                await sortChannel.send(())
            }
        }
    }
    
    var sortCategory: Market.SortCategory = .volume {
        didSet {
            Task {
                await sortChannel.send(())
            }
        }
    }
    
    var volumeSortOrder: SortOrder = .descending {
        didSet {
            Task {
                await sortChannel.send(())
            }
        }
    }
    
    var rateSortOrder: SortOrder = .none {
        didSet {
            Task {
                await sortChannel.send(())
            }
        }
    }
    
    var filter: CoinFilter = .none {
        didSet {
            Task {
                await sortChannel.send(())
            }
        }
    }

    var sortedCoinIDs: [CoinID] = []
    
    @ObservationIgnored
    private var visibleCoinsChannel = AsyncChannel<Set<CoinListModel.ID>>()
    
    @ObservationIgnored
    private var searchCoinsChannel = AsyncChannel<String>()
    
    @ObservationIgnored
    private var sortChannel = AsyncChannel<Void>()
    
    @ObservationIgnored
    private var subscriptionSnapshot = Set<CoinID>()
    init(coinService: UpBitAPIService, tickerService: RealTimeTickerProvider) {
        self.coinService = coinService
        self.tickerService = tickerService
    }
}

extension MarketStore {
    
    func load() async {
        guard hasLoaded == false else { return }
        defer { hasLoaded = true }
        await setup()
        
        Task {
            let stream = searchCoinsChannel
                .debounce(for: .milliseconds(300))
            
            for await text in stream {
                searchText = text
            }
        }
        
        Task {
            let stream = sortChannel
                ._throttle(for: .milliseconds(300), latest: false)
            
            for await _ in stream {
                await sort()
            }
        }
    }
    
    func refresh() async {
        await setup()
    }
    
    func update(_ items: [CoinID]) async {
        self.bookmarkIDs = Set(items)
    }
    
    func ticker(for id: CoinID) -> TickerStore? {
        ticker[id]
    }
    
    private func setup() async {
        (coinMeta, ticker) = await fetchMarketCoinData()
        await sort()
        await saveBookmarkSummaryToWidget()
    }
    
    func sort() async {
        
        let metas: [CoinID: Coin]
        
        switch filter {
        case .none:
            metas = coinMeta
        case .bookmark:
            metas = coinMeta.filter { bookmarkIDs.contains($0.key) }
        }
        
        let text = searchText
        
        let filteredCoinID: Set<CoinID>
        
        if searchText.isEmpty {
            filteredCoinID = Set(metas.map(\.key))
        } else {
            filteredCoinID = metas
                .filter { key, value in
                    value.koreanName.contains(text)
                }
                .map(\.key)
                .reduce(into: Set<CoinID>(), { acc, e in
                    acc.insert(e)
                })
        }
        
        let filteredTickers = ticker.map(\.value)
            .filter { filteredCoinID.contains($0.coinID) }
        
        switch sortCategory {
        case .rate:
            self.sortedCoinIDs = filteredTickers
                .sorted {
                    switch rateSortOrder {
                    case .ascending, .none:
                        $0.signedRate < $1.signedRate
                    case .descending:
                        $0.signedRate > $1.signedRate
                    }
                }
                .map(\.coinID)
        case .volume:
            self.sortedCoinIDs = filteredTickers
                .sorted {
                    switch volumeSortOrder {
                    case .ascending, .none:
                        $0.snapshot.volume < $1.snapshot.volume
                    case .descending:
                        $0.snapshot.volume > $1.snapshot.volume
                    }
                }
                .map(\.coinID)
        }
    }
    
    func search(_ text: String) async {
        await searchCoinsChannel.send(text)
    }
    
    private func fetchMarketCoinData() async -> ([CoinID: Coin], [CoinID: TickerStore]) {
        do {
            async let meta = try await coinService.fetchMarkets()
                .reduce(into: [CoinID: Coin]()) { acc, dto in
                    acc[dto.coinID] = Coin(id: dto.coinID, koreanName: dto.koreanName)
                }
            async let tickers = (try? await coinService.fetchTicker(by: "KRW")) ?? []
            
            var acc = [CoinID: TickerStore]()
            for coin in try await meta {
                let store = TickerStore(coinID: coin.key)
                if let ticker = await tickers.first(where: { $0.id == coin.key }) {
                    store.apply(ticker)
                }
                acc[coin.key] = store
            }
            
            return (try await meta, acc)
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
        if !subscriptionSnapshot.isEmpty {
            await sendTicket(subscriptionSnapshot)
        }
        
        // 시세가
        self.tickerStreamTask = Task {
            await consume()
        }
    }
    
    /// 서비스 연결 해제
    ///  coin snapshot 채널 종료
    func disconnect() async {
        visibleCoinsChannel.finish()
        self.ticketStreamTask?.cancel()
        self.tickerStreamTask?.cancel()
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
            .debounce(for: .milliseconds(300))
        for await visibleCoin in stream {
            self.subscriptionSnapshot = visibleCoin
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

extension MarketStore {
    func addRecord(_ id: CoinID) {
        try? searchRecordManager.save(query: id)
    }

    func deleteRecord(_ id: CoinID) {
        try? searchRecordManager.delete(query: id)
    }
}

extension MarketStore {
    /// 북마크된 코인의 시세 요약을 위젯에 저장 (히스토리 포함, 캔들 API 활용)
    func saveBookmarkSummaryToWidget() async {
        let bookmarks = (try? BookmarkManager.shared.fetchAll()) ?? []

        let nameMap = Dictionary(uniqueKeysWithValues: bookmarks.map { ($0.coinID, $0.coinKoreanName) })

        let bookmarkIDs = Set(bookmarks.map { $0.coinID })
        let bookmarkTickers = bookmarkIDs.compactMap { ticker[$0] }

        var summaries: [WidgetCoinSummary] = []

        for t in bookmarkTickers {
            // 캔들 데이터 가져오기 (최근 10분봉)
            let candles = try? await coinService.fetchCandles(id: t.coinID, count: 10)
            let history = candles?.map { $0.tradePrice }.reversed() ?? []

            let summary = WidgetCoinSummary(
                id: t.coinID,
                koreanName: nameMap[t.coinID] ?? "",
                price: t.snapshot.price,
                change: t.snapshot.signedRate * 100,
                history: Array(history)
            )
            summaries.append(summary)
        }

        // UserDefaults 저장
        let defaults = UserDefaults(suiteName: "group.com.est.ai.AIProject.CoinWidget")
        print("위젯 UserDault에 저장됨 ------", summaries)
        if let data = try? JSONEncoder().encode(summaries) {
            defaults?.set(data, forKey: "widgetSummary")
        }

        WidgetCenter.shared.reloadTimelines(ofKind: "CoinWidget")
    }
}
