//
//  TodayCoinInsightViewModel.swift
//  AIProject
//
//  Created by 장지현 on 8/6/25.
//

import Foundation

/// 오늘의 코인 시장/커뮤니티 인사이트를 제공하는 뷰 모델입니다.
///
/// AI 또는 커뮤니티 기반의 인사이트를 비동기적으로 불러오고,
/// 감정(Sentiment)과 요약(summary)을 제공합니다.
final class TodayCoinInsightViewModel: ObservableObject {
    @Published var overViewSentiment: Sentiment? = nil
    @Published var communitySentiment: Sentiment? = nil
    @Published var overViewSummary: String = ""
    @Published var communitySummary: String = ""
    @Published var overviewStatus: ResponseStatus = .loading
    @Published var communityStatus: ResponseStatus = .loading
    
    let alanAPIService = AlanAPIService()
    let redditAPIService = RedditAPIService()
    
    private var overallTask: Task<Void, Never>?
    private var communityTask: Task<Void, Never>?
    
    init() {
        overallTask = Task { await fetchOverallAsync() }
        communityTask = Task { await fetchCommunityAsync() }
    }
    
    /// AI 기반의 전체 인사이트를 비동기적으로 가져옵니다.
    private func fetchOverallAsync() async {
        do {
            let data = try await alanAPIService.fetchTodayInsight()
            
            await MainActor.run {
                overViewSentiment = Sentiment.from(data.todaysSentiment)
                overViewSummary = data.summary
                overviewStatus = .success
            }
        } catch {
            guard let ne = error as? NetworkError else { return print(error) }
            
            print(ne.log())
            await MainActor.run {
                overviewStatus = .failure(ne)
            }
        }
    }
    
    /// 커뮤니티 기반 인사이트를 비동기적으로 가져옵니다.
    ///
    /// Reddit에서 데이터를 수집하고, 해당 내용을 요약 요청하여 감정과 요약을 설정합니다.
    private func fetchCommunityAsync() async {
        do {
            let redditData = try await redditAPIService.fetchData()
            
            let redditSummary = redditData.enumerated().reduce(into: "") { result, element in
                let (index, item) = element
                
                result += "제목\(index): \(item.data.title)"
                if !item.data.content.isEmpty {
                    result += "\n내용\(index): \(item.data.content)"
                }
                result += "\n"
            }
                .trimmingCharacters(in: .newlines)
            
            let alanData = try await alanAPIService.fetchCommunityInsight(from: redditSummary)
            
            await MainActor.run {
                communitySentiment = Sentiment.from(alanData.todaysSentiment)
                communitySummary = alanData.summary
                
                if overviewStatus != .loading {
                    communityStatus = .success
                }
            }
        } catch {
            guard let ne = error as? NetworkError else { return print(error) }
            
            print(ne.log())
            await MainActor.run {
                communityStatus = .failure(ne)
            }
        }
    }
}
