//
//  InsightViewModel.swift
//  AIProject
//
//  Created by 장지현 on 8/6/25.
//

import Foundation

/// 오늘의 코인 시장/커뮤니티 인사이트를 제공하는 뷰 모델입니다.
///
/// AI 또는 커뮤니티 기반의 인사이트를 비동기적으로 불러오고,
/// 감정(`Sentiment`)과 요약(`summary`)을 제공합니다.
///
/// - Properties:
///   - overall: 오늘의 전체 시장 인사이트 상태(`FetchState<Insight>`)
///   - community: 커뮤니티 기반 인사이트 상태(`FetchState<Insight>`)
final class InsightViewModel: ObservableObject {
    @Published var overall: FetchState<Insight> = .loading
    @Published var community: FetchState<Insight> = .loading
    
    private let alanAPIService = AlanAPIService()
    private let redditAPIService = RedditAPIService()
    
    private var overallTask: Task<InsightDTO, Error>?
    private var communityTask: Task<InsightDTO, Error>?
    
    private var communityMonitor: Task<Void, Never>?
    
    init() {
        load()
    }
    
    private func load() {
        cancelAll()
        
        Task { @MainActor in
            overall = .loading
            community = .loading
        }
        
        overallTask = Task { try await alanAPIService.fetchTodayInsight() }
        communityTask = Task { try await fetchCommunityFlow() }
        
        if let t = communityTask {
            communityMonitor = t.monitorCancellation { [weak self] in
                self?.community = .cancel(.taskCancelled)
            }
        }
        
        Task {
            do {
                let data = try await overallTask?.value
                if let data {
                    let insight = Insight(sentiment: Sentiment(rawValue: data.todaysSentiment) ?? .neutral, summary: data.summary)
                    await MainActor.run { overall = .success(insight) }
                }
            } catch {
                if error.isTaskCancellation {
                    await MainActor.run { overall = .cancel(.taskCancelled) }
                    return
                }
                
                guard let ne = error as? NetworkError else { return print(error) }
                print(ne.log())
                await MainActor.run { overall = .failure(ne) }
            }
            
            try? await Task.sleep(for: .milliseconds(350))
            
            do {
                let data = try await communityTask?.value
                if let data {
                    let insight = Insight(sentiment: Sentiment(rawValue: data.todaysSentiment) ?? .neutral, summary: data.summary)
                    await MainActor.run { community = .success(insight) }
                }
            } catch {
                if error.isTaskCancellation {
                    await MainActor.run { community = .cancel(.taskCancelled) }
                    return
                }
                
                guard let ne = error as? NetworkError else { return print(error) }
                print(ne.log())
                await MainActor.run { community = .failure(ne) }
            }
        }
    }
    
    /// 커뮤니티 기반 인사이트를 비동기적으로 가져옵니다.
    ///
    /// Reddit에서 데이터를 수집하고, 해당 내용을 요약 요청하여 감정과 요약을 설정합니다.
    private func fetchCommunityFlow() async throws -> InsightDTO {
        let communityData = try await redditAPIService.fetchData()
        
        return try await alanAPIService.fetchCommunityInsight(from: makeCommunitySummary(from: communityData))
    }
    
    func cancelOverall() { overallTask?.cancel() }
    func cancelCommunity() { communityTask?.cancel() }
    
    func cancelAll() {
        communityMonitor?.cancel()
        overallTask?.cancel()
        communityTask?.cancel()
    }
    
    deinit {
        cancelAll()
    }
}

extension InsightViewModel {
    /// Reddit 게시글 데이터 배열을 요약 문자열로 변환합니다.
    ///
    /// 각 게시글의 제목과 본문을 순서대로 결합하여, AI 요약 요청에 전달할 수 있는 하나의 문자열로 만듭니다.
    ///
    /// - Parameter data: Reddit 게시글 DTO 배열
    /// - Returns: 게시글 제목과 내용을 포함한 요약 문자열
    fileprivate func makeCommunitySummary(from data: [RedditDTO.RedditResponseDTO.RedditPostDTO]) -> String {
        data.enumerated().reduce(into: "") { result, element in
            let (index, item) = element
            
            result += "제목\(index): \(item.data.title)"
            if !item.data.content.isEmpty {
                result += "\n내용\(index): \(item.data.content)"
            }
            result += "\n"
        }
        .trimmingCharacters(in: .newlines)
    }
}
