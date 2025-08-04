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
    @Published var coinOverView: String = "AI가 정보를 준비하고 있어요"
    @Published var coinTodayTrends: String = "AI가 정보를 준비하고 있어요"
    @Published var coinWeeklyTrends: String = "AI가 정보를 준비하고 있어요"
    @Published var coinTodayTopNews: [CoinArticle] = [CoinArticle(title: "", summary: "AI가 정보를 준비하고 있어요", url: "https://example.com/news1")]
    
    init(coin: Coin) {
        self.coin = coin
        self.koreanName = coin.koreanName
        fetchOverView()
        fetchTodayTopNews()
        fetchWeeklyTrends()
    }
    
    private func fetch<T: Decodable>(
        content: String,
        decodeType: T.Type,
        onSuccess: @escaping (T) -> Void,
        onFailure: @escaping () -> Void
    ) {
        Task {
            do {
                let answer = try await AlanAPIService().fetchAnswer(content: content)
                guard let jsonData = answer.content.extractedJSON.data(using: .utf8) else {
                    await MainActor.run { onFailure() }
                    return
                }
                let data = try JSONDecoder().decode(T.self, from: jsonData)
                await MainActor.run { onSuccess(data) }
            } catch {
                print("오류 발생: \(error.localizedDescription)")
                await MainActor.run { onFailure() }
            }
        }
    }
    
    private func fetchOverView() {
        let content = """
        struct CoinOverviewDTO: Codable {
            let symbol: String 
            let websiteURL: String?
            let launchDate: String
            let description: String
        }
        
        "\(coin.koreanName)" 개요를 위 JSON 형식으로 작성 (마크다운 금지)
        """
        
        fetch(
            content: content,
            decodeType: CoinOverviewDTO.self,
            onSuccess: { data in
                self.coinOverView = """
                    ‣ 심볼: \(data.symbol)
                    ‣ 웹사이트: \(data.websiteURL ?? "없음")
                    
                    ‣ 최초발행: \(data.launchDate)
                    
                    ‣ 소개: \(data.description)
                    """
            },
            onFailure: {
                self.coinOverView = "데이터를 불러오는 데 실패했어요"
            }
        )
    }
    
    private func fetchTodayTopNews() {
        let content = """
        struct CoinTodayNewsDTO: Codable {
            let todaySentiment: String
            let articles: [CoinArticleDTO]
        }
        
        struct CoinArticleDTO: Codable {
            let title: String
            let summary: String
            let url: String
        }
        
        1. 현재 국내 시간을 기준으로 최근 24시간 뉴스 기반
        2. 뉴스 전반을 분석해 시장 분위기를 요약
        
        위 조건에 따라 "\(coin.koreanName)"에 대한 내용을 위 JSON 형식으로 작성 (마크다운 금지)
        """
        
        fetch(
            content: content,
            decodeType: CoinTodayNewsDTO.self,
            onSuccess: { data in
                self.coinTodayTrends = data.todaySentiment
                self.coinTodayTopNews = data.articles.map { CoinArticle(from: $0) }
            },
            onFailure: {
                self.coinTodayTrends = "데이터를 불러오는 데 실패했어요"
                self.coinTodayTopNews = [CoinArticle(title: "데이터를 불러오는데 실패했어요", summary: "", url: "")]
            }
        )
    }
    
    private func fetchWeeklyTrends() {
        let content = """
            struct CoinWeeklyDTO: Codable {
                let priceTrend: String
                let volumeChange: String
                let reason: String
            }
            
            1. 현재 국내 시간을 기준으로 일주일 동안의 정보 사용
        
            위 조건에 따라 "\(coin.koreanName)"에 대한 내용을 위 JSON 형식으로 작성 (마크다운 금지)
        """
        
        fetch(
            content: content,
            decodeType: CoinWeeklyDTO.self,
            onSuccess: { data in
                self.coinWeeklyTrends = """
                    ‣ 가격 추이: \(data.priceTrend)
                    
                    ‣ 거래량 변화: \(data.volumeChange)
                    
                    ‣ 원인: \(data.reason)
                    """
            },
            onFailure: {
                self.coinWeeklyTrends = "데이터를 불러오는 데 실패했어요"
            }
        )
    }
}
