//
//  ReportViewModel.swift
//  AIProject
//
//  Created by 장지현 on 8/1/25.
//

import Foundation

final class ReportViewModel: ObservableObject {
    let coin: Coin
    let koreanName: String
    
    private let alanAPIService = AlanAPIService()
    
    @Published var coinOverView: String = "AI가 정보를 준비하고 있어요"
    @Published var coinTodayTrends: String = "AI가 정보를 준비하고 있어요"
    @Published var coinWeeklyTrends: String = "AI가 정보를 준비하고 있어요"
    @Published var coinTodayTopNews: [CoinArticle] = [CoinArticle(title: "", summary: "AI가 정보를 준비하고 있어요", url: "https://example.com/")]
    
    init(coin: Coin) {
        self.coin = coin
        self.koreanName = coin.koreanName
        
        Task.detached(priority: .background) {
            await self.fetchOverViewAsync()
            await self.fetchTodayTopNewsAsync()
            await self.fetchWeeklyTrendsAsync()
        }
    }
    
    private func fetchOverViewAsync() async {
        do {
            let data = try await alanAPIService.fetchOverview(for: coin)
            await MainActor.run {
                self.coinOverView = """
                    ‣ 심볼: \(data.symbol)
                    ‣ 웹사이트: \(data.websiteURL ?? "없음")
                    
                    ‣ 최초발행: \(data.launchDate)
                    
                    ‣ 소개: \(data.description)
                    """
            }
        } catch {
            print("오류 발생: \(error.localizedDescription)")
            await MainActor.run {
                self.coinOverView = "데이터를 불러오는 데 실패했어요"
            }
        }
    }
    
    private func fetchTodayTopNewsAsync() async {
        do {
            let data = try await alanAPIService.fetchTodayNews(for: coin)
            await MainActor.run {
                self.coinTodayTrends = data.summaryOfTodaysMarketSentiment
                self.coinTodayTopNews = data.articles.map { CoinArticle(from: $0) }
            }
        } catch {
            print("오류 발생: \(error.localizedDescription)")
            await MainActor.run {
                self.coinTodayTrends = "데이터를 불러오는 데 실패했어요"
                self.coinTodayTopNews = [CoinArticle(title: "데이터를 불러오는데 실패했어요", summary: "", url: "")]
            }
        }
    }
    
    private func fetchWeeklyTrendsAsync() async {
        do {
            let data = try await alanAPIService.fetchWeeklyTrends(for: coin)
            await MainActor.run {
                self.coinWeeklyTrends = """
                    ‣ 가격 추이: \(data.priceTrend)
                    
                    ‣ 거래량 변화: \(data.volumeChange)
                    
                    ‣ 원인: \(data.reason)
                    """
            }
        } catch {
            print("오류 발생: \(error.localizedDescription)")
            await MainActor.run {
                self.coinWeeklyTrends = "데이터를 불러오는 데 실패했어요"
            }
        }
    }
}
