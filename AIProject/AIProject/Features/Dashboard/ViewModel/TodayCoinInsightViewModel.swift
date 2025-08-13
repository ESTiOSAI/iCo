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
    /// AI가 분석한 감정 결과입니다.
    @Published var sentiment: Sentiment = .neutral
    /// AI 또는 커뮤니티 기반의 요약 내용입니다.
    @Published var summary: String = "AI가 정보를 준비하고 있어요"
    
    @Published var overviewStatus: ResponseStatus = .loading
    @Published var communityStatus: ResponseStatus = .loading
    
    /// 커뮤니티 기반 인사이트인지 여부입니다.
    let isCommunity: Bool
    let alanAPIService = AlanAPIService()
    let redditAPIService = RedditAPIService()
    
    init(isCommunity: Bool = false) {
        self.isCommunity = isCommunity
        Task {
            // FIXME: 순서대로 요청하도록 수정
            await !isCommunity ? fetchOverallAsync() : fetchCommunityAsync()
        }
    }
    
    /// AI 기반의 전체 인사이트를 비동기적으로 가져옵니다.
    private func fetchOverallAsync() async {
        do {
            let data = try await alanAPIService.fetchTodayInsight()
            
            await MainActor.run {
                sentiment = Sentiment.from(data.todaysSentiment)
                self.summary = data.summary
                self.overviewStatus = .success
            }
        } catch {
            guard let ne = error as? NetworkError else { return print(error) }
            
            print(ne.log())
            await MainActor.run {
                self.overviewStatus = .failure(ne)
            }
        }
    }
    
    /// 커뮤니티 기반 인사이트를 비동기적으로 가져옵니다.
    ///
    /// Reddit에서 데이터를 수집하고, 해당 내용을 요약 요청하여 감정과 요약을 설정합니다.
    private func fetchCommunityAsync() async {
        do {
            let communityData = try await redditAPIService.fetchData()
            
            let communitySummary = communityData.enumerated().reduce(into: "") { result, element in
                let (index, item) = element
                
                result += "제목\(index): \(item.data.title)"
                if !item.data.content.isEmpty {
                    result += "\n내용\(index): \(item.data.content)"
                }
                result += "\n"
            }
                .trimmingCharacters(in: .newlines)
            
            let alanData = try await alanAPIService.fetchCommunityInsight(from: communitySummary)
            
            await MainActor.run {
                sentiment = Sentiment.from(alanData.todaysSentiment)
                self.summary = alanData.summary
                self.communityStatus = .success
            }
        } catch {
            guard let ne = error as? NetworkError else { return print(error) }
            
            print(ne.log())
            await MainActor.run {
                self.communityStatus = .failure(ne)
            }
        }
    }
}
