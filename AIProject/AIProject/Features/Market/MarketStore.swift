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

/// 마켓 이벤트 처리를 담당
/// 검색 / 시세 정보 / 웹소켓 상태 / 정렬 / 필터링 이벤트 처리
@MainActor
@Observable
class MarketStore {
    
    /// 최초 한 번만 로드하기 위한 flag
    private var hasLoaded = false
    
    /// 실시간 시세 구독 티켓
    private let ticket = UUID().uuidString
    
    private let coinService: UpBitAPIService
    private let tickerService: RealTimeTickerProvider
    private let searchRecordManager: SearchRecordManaging = SearchRecordManager()
    
    private(set) var errorMessage: String?
    
    /// 변동성이 적은 메타 정보
    private(set) var coinMeta: [CoinID: Coin] = [:]
    
    /// 변동성이 큰 시세 정보
    private var ticker: [CoinID: TickerStore] = [:]
    
    /// 코인 구독 신청 stream task
    private var ticketStreamTask: Task<Void, Never>?
    
    /// 코인 시세 stream task
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
    
    /// 아래 멤버들은 View 갱신을 최소화하기 위해 사용
    /// 현재 보여지는 코인 구독 최적화를 위한 채널
    @ObservationIgnored
    private var visibleCoinsChannel = AsyncChannel<Set<CoinListModel.ID>>()
    
    /// 검색 최적화를 위한 채널
    @ObservationIgnored
    private var searchCoinsChannel = AsyncChannel<String>()
    
    /// 정렬 최적화를 위한 채널
    @ObservationIgnored
    private var sortChannel = AsyncChannel<Void>()
    
    /// 소켓이 끊길 경우 마지막에 구독한 코인을 재구독하기 위한 값
    @ObservationIgnored
    private var subscriptionSnapshot = Set<CoinID>()
    
    init(coinService: UpBitAPIService, tickerService: RealTimeTickerProvider) {
        self.coinService = coinService
        self.tickerService = tickerService
        print("init" + String(describing: Self.self))
    }
    
    deinit {
        print(#function, String(describing: Self.self))
    }
}

extension MarketStore {
    
    func load() async {
        guard hasLoaded == false else { return }
        defer { hasLoaded = true }
        await setup()
        
        // stream이 종료되어야 다음라인이 실행되므로 별도 Task로 분리
        // 검색에 debounce 적용
        Task {
            let stream = searchCoinsChannel
                .debounce(for: .milliseconds(300))
            
            for await text in stream {
                searchText = text
            }
        }
        
        // 정렬에 throttle 적용
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
    
    // 북마크 갱신
    func update(_ items: [CoinID]) async {
        self.bookmarkIDs = Set(items)
    }
    
    // 시세 Store 객체를 반환함
    func ticker(for id: CoinID) -> TickerStore? {
        ticker[id]
    }
    
    private func setup() async {
        (coinMeta, ticker) = await fetchMarketCoinData()
        await sort()
        await saveBookmarkSummaryToWidget()
    }
    
    func sort() async {
        // 필터링은 중복데이터 방지와 index가 필요 없어 Set으로 관리하고
        // 정렬은 Array로 관리
        
        let metas: [CoinID: Coin]
        // 필터링 프로세스
        switch filter {
        case .none:
            metas = coinMeta
        case .bookmark:
            metas = coinMeta.filter { bookmarkIDs.contains($0.key) }
        }
        
        let text = searchText.localizedLowercase
        
        let filteredCoinID: Set<CoinID>
        
        if searchText.isEmpty {
            filteredCoinID = Set(metas.map(\.key))
        } else {
            // 한글명이나 영문 심볼 검색
            filteredCoinID = metas
                .filter { key, value in
                    value.koreanName.contains(text) || value.coinSymbol.localizedLowercase.contains(text)
                }
                .map(\.key)
                .reduce(into: Set<CoinID>(), { acc, e in
                    acc.insert(e)
                })
        }
        
        let filteredTickers = filteredCoinID
            .compactMap { ticker[$0] }
        
        // 정렬 프로세스
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
    
    /// 메타정보와 국장 코인 초기 시세 정보를 불러옵니다.
    /// - Returns: 메타 정보와 시세정보를 dictionary 형태로 반환
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

// MARK: Ticker 서비스

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
    
    /// 웹소켓이 죽는 걸 방지하기 위해 보내는 구독 신청을 최적화
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
    
    /// 시세 정보를 stream으로 받아서 업데이트
    private func consume() async {
        for try await ticker in tickerService.subscribeTickerStream() {
            await performUpdate(ticker)
        }
    }
    
    private func performUpdate(_ ticker: TickerValue) async {
        guard let store = self.ticker[ticker.id] else { return }
        store.apply(ticker)
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
        let defaults = UserDefaults(suiteName: AppGroup.suite)
        if let data = try? JSONEncoder().encode(summaries) {
            defaults?.set(data, forKey: "widgetSummary")
        }

        WidgetCenter.shared.reloadTimelines(ofKind: "CoinWidget")
    }
}
