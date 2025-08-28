//
//  ReportViewModel.swift
//  AIProject
//
//  Created by 장지현 on 8/1/25.
//

import Foundation

/// AI를 활용한 코인 리포트를 생성하는 뷰 모델입니다.
///
/// 코인 개요, 주간 동향, 오늘의 시장 요약, 주요 뉴스 목록을 비동기적으로 가져옵니다.
/// `AlanAPIService`를 통해 데이터를 요청하고, UI에 표시할 형식으로 가공합니다.
///
/// - Parameters:
///   - coin: 보고서 생성의 대상이 되는 코인입니다.
///
/// - Properties:
///   - overview: 코인 개요 상태(`FetchState<AttributedString>`)
///   - weekly: 주간 동향 상태(`FetchState<AttributedString>`)
///   - today: 오늘의 시장 요약 상태(`FetchState<AttributedString>`)
///   - news: 오늘의 뉴스 기사 목록
final class ReportViewModel: ObservableObject {
    @Published var overview: FetchState<AttributedString> = .loading
    @Published var weekly: FetchState<AttributedString> = .loading
    @Published var today: FetchState<AttributedString> = .loading
    @Published var news: [CoinArticle] = [CoinArticle(title: "", summary: "AI가 정보를 준비하고 있어요", newsSourceURL: "https://example.com/")]
    
    let coin: Coin
    let koreanName: String
    
    private let alanAPIService = AlanAPIService()
    
    private var overviewTask: Task<CoinOverviewDTO, Error>?
    private var weeklyTask: Task<CoinWeeklyDTO, Error>?
    private var todayTask: Task<CoinTodayNewsDTO, Error>?
    
    private var hasStarted = false
    
    init(coin: Coin) {
        self.coin = coin
        self.koreanName = coin.koreanName
    }
    
    func load() async {
        cancelAll()
        
        await MainActor.run {
            overview = .loading
            weekly = .loading
            today = .loading
        }
        
        overviewTask = Task { try await alanAPIService.fetchOverview(for: coin) }
        
        weeklyTask = Task { [weak self] in
            try await withTaskCancellationHandler(
                operation: {
                    guard let self else { throw CancellationError() }
                    return try await self.alanAPIService.fetchWeeklyTrends(for: self.coin)
                },
                onCancel: { [weak self] in
                    self?.weekly = .cancel(.taskCancelled)
                },
                isolation: MainActor.shared
            )
        }
        
        todayTask = Task { [weak self] in
            try await withTaskCancellationHandler(
                operation: {
                    guard let self else { throw CancellationError() }
                    return try await self.alanAPIService.fetchTodayNews(for: self.coin)
                },
                onCancel: { [weak self] in
                    self?.today = .cancel(.taskCancelled)
                },
                isolation: MainActor.shared
            )
        }
        
        await updateOverviewUI()
        try? await Task.sleep(for: .milliseconds(350)) // UI가 순차적으로 적용되는 효과를 주기 위한 딜레이
        await updateWeeklyUI()
        try? await Task.sleep(for: .milliseconds(350)) // UI가 순차적으로 적용되는 효과를 주기 위한 딜레이
        await updateTodayUI()
    }
    
    /// 탭에서 Report가 처음 표시될 때 한 번만 로드합니다.
    @MainActor
    func startIfNeeded() async {
        guard !hasStarted else { return }
        hasStarted = true
        await load()
    }
    
    // overview만 다시 시도
    func retryOverview() {
        if overview.isLoading { return }
        overviewTask?.cancel()
        
        Task { @MainActor in
            overview = .loading
        }
        
        overviewTask = Task { try await alanAPIService.fetchOverview(for: coin) }
        
        Task {
            await updateOverviewUI()
        }
    }
    
    // weekly만 다시 시도
    func retryWeekly() {
        if weekly.isLoading { return }
        weeklyTask?.cancel()
        
        Task { @MainActor in
            weekly = .loading
        }
        
        weeklyTask = Task { try await alanAPIService.fetchWeeklyTrends(for: coin) }
        
        Task {
            await updateWeeklyUI()
        }
    }
    
    // retry만 다시 시도
    func retryToday() {
        if today.isLoading { return }
        todayTask?.cancel()
        
        Task { @MainActor in
            today = .loading
        }
        
        todayTask = Task { try await alanAPIService.fetchTodayNews(for: coin) }
        
        Task {
            await updateTodayUI()
        }
    }
    
    func cancelOverview() { overviewTask?.cancel() }
    func cancelWeekly() { weeklyTask?.cancel() }
    func cancelToday() { todayTask?.cancel() }
    
    func cancelAll() {
        overviewTask?.cancel()
        weeklyTask?.cancel()
        todayTask?.cancel()
    }
    
    deinit {
        cancelAll()
        print(String(describing: Self.self), #function)
    }
}

extension ReportViewModel {
    private func updateOverviewUI() async {
        await TaskResultHandler.apply(
            of: overviewTask,
            using: { data in
                data.overview
            },
            update: { [weak self] state in
                self?.overview = state
            }
        )
    }
    
    private func updateWeeklyUI() async {
        await TaskResultHandler.apply(
            of: weeklyTask,
            using: { data in
                data.weekly
            },
            update: { [weak self] state in
                self?.weekly = state
            }
        )
    }
    
    private func updateTodayUI() async {
        await TaskResultHandler.apply(
            of: todayTask,
            using: { data in
                data.today
            },
            update: { [weak self] state in
                self?.today = state
            },
            sideEffect: { [weak self] data in
                self?.news = data.articles.map { CoinArticle(from: $0) }
            }
        )
    }
}

extension ReportViewModel {
    var sectionDataSource: [ReportSectionData<AttributedString>] {
        [
            ReportSectionData(
                id: "overview",
                icon: "text.page.badge.magnifyingglass",
                title: "한눈에 보는 \(koreanName)",
                state: overview,
                onCancel: { [weak self] in self?.cancelOverview() },
                onRetry: { [weak self] in self?.retryOverview() }
            ),
            ReportSectionData(
                id: "weekly",
                icon: "calendar",
                title: "주간 동향",
                state: weekly,
                onCancel: { [weak self] in self?.cancelWeekly() },
                onRetry: { [weak self] in self?.retryWeekly() }
            ),
            ReportSectionData(
                id: "today",
                icon: "shareplay",
                title: "오늘 시장의 분위기",
                state: today,
                onCancel: { [weak self] in self?.cancelToday() },
                onRetry: { [weak self] in self?.retryToday() }
            ),
        ]
    }
}
