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
                switch data.todaysSentiment {
                case "호재":
                    sentiment = .positive
                case "중립":
                    sentiment = .neutral
                case "악재":
                    sentiment = .negative
                default:
                    sentiment = .neutral
                    // TODO: 새로고침
                }
                
                self.summary = ""
                
                for (key, values) in data.summary {
                    if data.summary.count > 1 {
                        self.summary.append("‣ \(key) 소식\n")
                    }
                    for value in values {
                        self.summary.append("\(value)\n")
                    }
                }
                
                self.summary = self.summary.trimmingCharacters(in: .whitespacesAndNewlines)
                print(self.summary)
            }
        } catch {
            print("오류 발생: \(error.localizedDescription)")
            await MainActor.run {
                self.summary = "데이터를 불러오는 데 실패했어요"
            }
        }
    }
    
    private func fetchCommunityAsync() async {
        
    }
}
