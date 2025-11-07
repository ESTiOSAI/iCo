//
//  InsightViewModel.swift
//  AIProject
//
//  Created by 장지현 on 8/6/25.
//

import SwiftUI

/// 오늘의 코인 커뮤니티 분위기를 제공하는 뷰 모델입니다.
///
/// AI 또는 커뮤니티 기반의 분위기를 비동기적으로 불러오고,
/// 감정(`Sentiment`)과 요약(`summary`)을 제공합니다.
///
/// - Properties:
///   - community: 커뮤니티 기반 분위기(`FetchState<Insight>`)
final class InsightViewModel: ObservableObject {
    @AppStorage(AppStorageKey.cacheBriefCommunityTimestamp) private var cacheBriefCommunityTimestamp: String = ""
    
    @Published var community: FetchState<Insight> = .loading
    
    private let llmService = LLMAPIService()
    private let redditAPIService = RedditAPIService()
    
    private var communityTask: Task<Insight, Error>?
    
    init() {
        load()
    }
    
    private func load() {
        cancelAll()
        
        Task { @MainActor in
            community = .loading
        }
        
        communityTask = Task { [weak self] in
            try await withTaskCancellationHandler(
                operation: {
                    guard let self else { throw CancellationError() }
                    return try await self.fetchCommunityFlow()
                },
                onCancel: { [weak self] in
                    self?.community = .cancel(.taskCancelled)
                },
                isolation: MainActor.shared
            )
        }
        
        Task {
            await updateCommunityUI()
        }
    }
    
    // Reddit 데이터를 가져와 요약 후 인사이트 생성
    private func fetchCommunityFlow(ignoreCache: Bool = false) async throws -> Insight {
        let communityData = try await redditAPIService.fetchData()
        
        return try await llmService.fetchCommunityInsight(from: communityData.communitySummary, ignoreCache: ignoreCache)
    }
    
    // community만 다시 시도
    func retryCommunity() {
        if community.isLoading { return }
        communityTask?.cancel()
        
        communityTask = nil
        
        Task {
            await MainActor.run { community = .loading }
            try? await Task.sleep(for: .milliseconds(350)) // 새로고침 효과를 주기 위한 딜레이
            communityTask = Task { try await fetchCommunityFlow(ignoreCache: true) }
            await updateCommunityUI()
        }
    }
    
    func cancelCommunity() {
        communityTask?.cancel()
    }
    
    func cancelAll() {
        communityTask?.cancel()
    }
    
    deinit {
        cancelAll()
    }
}

extension InsightViewModel {
    private func updateCommunityUI() async {
        await TaskResultHandler.apply(
            of: communityTask,
            update: { [weak self] state in
                self?.community = state
            }
        )
    }
}

extension InsightViewModel {
    var sectionDataSource: [ReportSectionData<Insight>] {
        [
            ReportSectionData(
                id: "community",
                icon: "shareplay",
                title: "주요 커뮤니티의 분위기",
                state: community,
                timestamp: Date.dateAndTimeFormatter.date(from: cacheBriefCommunityTimestamp),
                onCancel: { [weak self] in self?.cancelCommunity() },
                onRetry: { [weak self] in self?.retryCommunity() }
            ),
        ]
    }
}
