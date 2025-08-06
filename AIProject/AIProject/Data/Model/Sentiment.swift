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
/// 각 케이스는 색상(`color`)과 설명(`description`)을 제공합니다.
enum Sentiment {
    case positive
    case neutral
    case negative
    
    /// 시장 감정에 따라 시각적으로 표현할 색상을 반환합니다.
    var color: Color {
        switch self {
        case .positive:
            return .aiCoPositive
        case .negative:
            return .aiCoNegative
        case .neutral:
            return .gray // FIXME: 중립 색상 만들기
        }
    }
    
    /// 각 감정에 대한 한글 설명을 제공합니다.
    var description: String {
        switch self {
        case .positive: return "호재"
        case .negative: return "악재"
        case .neutral: return "중립"
        }
    }
}

extension Sentiment {
    /// 문자열로부터 `Sentiment` 값을 생성합니다.
    ///
    /// - Parameter string: "호재", "악재", "중립" 등과 같은 문자열 값
    /// - Returns: 해당 문자열에 대응하는 `Sentiment` 값. 알 수 없는 문자열은 `.neutral`을 반환합니다.
    static func from(_ string: String) -> Sentiment {
        switch string {
        case "호재": return .positive
        case "중립": return .neutral
        case "악재": return .negative
        default: return .neutral // TODO: 새로고침 버튼 만들기
        }
    }
}
