//
//  TodayCoinInsightViewModel.swift
//  AIProject
//
//  Created by 장지현 on 8/6/25.
//

import Foundation

final class TodayCoinInsightViewModel: ObservableObject {
    @Published var sentiment: Sentiment = .neutral
    @Published var summary: String = "AI가 정보를 준비하고 있어요"
    
    let isCommunity: Bool
    let alanAPIService = AlanAPIService()
    let redditAPIService = RedditAPIService()
    
    init(isCommunity: Bool = false) {
        self.isCommunity = isCommunity
        Task {
            await !isCommunity ? fetchOverallAsync() : fetchCommunityAsync()
        }
    }
    
    private func fetchOverallAsync() async {
        do {
            let data = try await alanAPIService.fetchTodayInsight()
            
            await MainActor.run {
                sentiment = Sentiment.from(data.todaysSentiment)
                
                self.summary = data.summary.map { key, values in
                    var content = ""
                    if data.summary.count > 1 {
                        content += "‣ \(key) 소식\n"
                    }
                    content += values.joined(separator: "\n")
                    return content
                }
                .joined(separator: "\n\n")
                .trimmingCharacters(in: .whitespacesAndNewlines)
            }
        } catch {
            print("오류 발생: \(error.localizedDescription)")
            await MainActor.run {
                self.summary = "데이터를 불러오는 데 실패했어요"
            }
        }
    }
    
    private func fetchCommunityAsync() async {
        do {
            let communityData = try await redditAPIService.fetchData()
            
            let communitySummary = communityData.enumerated().map { index, item in
                var entry = "제목\(index): \(item.data.title)"
                if !item.data.content.isEmpty {
                    entry += "\n내용\(index): \(item.data.content)"
                }
                return entry
            }
            .joined(separator: "\n\n")
            print(communitySummary)
            
            let alanData = try await alanAPIService.fetchCommunityInsight(from: communitySummary)
            
            await MainActor.run {
                sentiment = Sentiment.from(alanData.todaysSentiment)
                
                self.summary = alanData.summary
            }
        } catch {
            print("오류 발생: \(error.localizedDescription)")
            await MainActor.run {
                self.summary = "데이터를 불러오는 데 실패했어요"
            }
        }
    }
}
