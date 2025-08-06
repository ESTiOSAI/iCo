//
//  Sentiment.swift
//  AIProject
//
//  Created by 장지현 on 8/6/25.
//

import SwiftUI

enum Sentiment {
    case positive
    case neutral
    case negative
    
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

        var description: String {
            switch self {
            case .positive: return "호재"
            case .negative: return "악재"
            case .neutral: return "중립"
            }
        }
}
