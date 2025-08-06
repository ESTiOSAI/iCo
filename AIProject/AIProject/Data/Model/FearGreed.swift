//
//  FearGreed.swift
//  AIProject
//
//  Created by 장지현 on 8/6/25.
//

import SwiftUI

enum FearGreed: String {
    case extremeFear = "Extreme Fear"
    case fear = "Fear"
    case neutral = "Neutral"
    case greed = "Greed"
    case extremeGreed = "Extreme Greed"
    
    var color: Color {
        switch self {
        case .extremeFear:
            return .red
        case .fear:
            return .orange
        case .neutral:
            return .yellow
        case .greed:
            return .green
        case .extremeGreed:
            return .mint
        }
    }
    
    var description: String {
        switch self {
        case .extremeFear:
            return "극단적 공포"
        case .fear:
            return "공포"
        case .neutral:
            return "중립"
        case .greed:
            return "탐욕"
        case .extremeGreed:
            return "극단적 탐욕"
        }
    }
}

extension FearGreed {
    static func from(_ classification: String) -> FearGreed {
        switch classification {
        case "Extreme Fear":
            return .extremeFear
        case "Fear":
            return .fear
        case "Neutral":
            return .neutral
        case "Greed":
            return .greed
        case "Extreme Greed":
            return .extremeGreed
        default:
            return .neutral
        }
    }
}
