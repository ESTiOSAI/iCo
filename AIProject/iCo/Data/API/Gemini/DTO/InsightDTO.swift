//
//  InsightDTO.swift
//  AIProject
//
//  Created by 장지현 on 8/7/25.
//

import Foundation

struct InsightDTO: Codable {
    /// 분위기 (호재 / 악재 / 중립)
    let todaysSentiment: String
    
    /// 평가 이유
    let summary: String
}

extension InsightDTO {
    func toDomain() -> Insight {
        Insight(
            sentiment: Sentiment(rawValue: todaysSentiment) ?? .neutral,
            summary: summary
        )
    }
}
