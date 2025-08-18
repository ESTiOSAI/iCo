//
//  Insight.swift
//  AIProject
//
//  Created by 장지현 on 8/18/25.
//

import Foundation

/// 오늘의 코인 시장 또는 커뮤니티 분위기를 나타내는 모델입니다.
///
/// - Properties:
///   - sentiment: 분위기(`Sentiment`)
///   - summary: 분위기를 요약한 문자열
struct Insight {
    let sentiment: Sentiment
    let summary: String
}
