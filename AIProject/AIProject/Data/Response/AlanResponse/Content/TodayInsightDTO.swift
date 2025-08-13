//
//  TodayInsightDTO.swift
//  AIProject
//
//  Created by 장지현 on 8/6/25.
//

import Foundation

struct TodayInsightDTO: Codable {
    /// 오늘 암호화폐 전체 시장 분위기 (호재 / 악재 / 중립)
    let todaysSentiment: String
    
    /// 내용 요약
    let summary: String
}
