//
//  FearGreed.swift
//  AIProject
//
//  Created by 장지현 on 8/6/25.
//

import SwiftUI

/// 공포-탐욕 지수를 나타내는 열거형입니다.
///
/// 이 열거형은 암호화폐 시장의 심리를 다섯 단계로 분류합니다.
/// 각 단계는 색상(`color`)과 설명(`description`)을 제공합니다.
enum FearGreed: String {
    case extremeFear = "Extreme Fear"
    case fear = "Fear"
    case neutral = "Neutral"
    case greed = "Greed"
    case extremeGreed = "Extreme Greed"
    
    /// 지수 단계에 따라 시각적으로 표현할 색상을 반환합니다.
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
    
    /// 각 지수 단계에 대한 한글 설명을 제공합니다.
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
