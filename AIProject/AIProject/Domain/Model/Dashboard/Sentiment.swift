//
//  Sentiment.swift
//  AIProject
//
//  Created by 장지현 on 8/6/25.
//

import SwiftUI

/// 시장에 대한 감정(Sentiment)을 분류하는 열거형입니다.
///
/// 이 열거형은 긍정적, 중립적, 부정적 세 가지 시장 감정을 나타냅니다.
/// 각 케이스는 색상(`color`)을 제공합니다.
enum Sentiment: String {
    case positive = "호재"
    case neutral = "중립"
    case negative = "악재"

    /// 테마별로 시장 감정에 따라 시각적으로 표현할 색상을 반환합니다.
    func color(for theme: Theme) -> Color {
        switch self {
        case .positive: return theme.positiveColor
        case .negative: return theme.negativeColor
        case .neutral: return .aiCoNeutral
        }
    }
}
