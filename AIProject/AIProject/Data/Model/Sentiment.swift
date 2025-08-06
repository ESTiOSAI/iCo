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

extension Sentiment {
    static func from(_ string: String) -> Sentiment {
        switch string {
        case "호재": return .positive
        case "중립": return .neutral
        case "악재": return .negative
        default: return .neutral // TODO: 새로고침 버튼 만들기
        }
    }
}
