//
//  CommunityInsightDTO.swift
//  AIProject
//
//  Created by 장지현 on 8/7/25.
//

import Foundation

struct CommunityInsightDTO: Codable {
    /// 게시물을 기반으로 평가한 커뮤니티 분위기 (호재 / 악재 / 중립)
    let todaysSentiment: String
    
    /// 평가 이유
    let summary: String
}
