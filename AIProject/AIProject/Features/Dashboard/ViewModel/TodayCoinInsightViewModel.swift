//
//  TodayCoinInsightViewModel.swift
//  AIProject
//
//  Created by 장지현 on 8/6/25.
//

import Foundation

final class TodayCoinInsightViewModel: ObservableObject {
    @Published var sentiment: Sentiment = .positive
    @Published var summary: String = """
    비트코인은 약 $114,900~115,000 수준에서 반등하며 강세 흐름을 이어가고 있고, 이더리움 역시 최근 상승세를 보이며 투자자 심리를 지지하고 있습니다.
    연준의 금리 인하 기대가 커지면서 달러 약세 및 위험자산 선호로 전체적으로 긍정적인 투자 분위기가 조성되고 있습니다.
    다만, 이더리움에 대한 기관 자금 유입이 활발한 상황에서 스테이킹 관련 규제와 시장 변동성은 여전히 주의 요인입니다.
    """
    
    let isCommunity: Bool
    
    init(isCommunity: Bool = false) {
        self.isCommunity = isCommunity
        Task {
            await !isCommunity ? fetchOverallAsync() : fetchCommunityAsync()
        }
    }
    
    private func fetchOverallAsync() async {
        
    }
    
    private func fetchCommunityAsync() async {
        
    }
}
