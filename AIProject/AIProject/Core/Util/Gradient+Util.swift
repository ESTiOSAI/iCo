//
//  Gradient+Util.swift
//  AIProject
//
//  Created by Kitcat Seo on 8/7/25.
//

import SwiftUI

/// AICo UI에 맞춘 그라데이션 스타일 enum
/// - `default`: 기본 테마 색상
/// - `accent`: 강조 색상
///
/// 각 스타일에 대응하는 색상 배열을 반환하여 Gradient 생성에 사용하는 확장
extension Gradient {
    enum AICoGradientStyle {
        case `default`
        case accent
        
        var colors: [Color] {
            switch self {
            case .default:
                return [.aiCoGradientDefaultLight, .aiCoGradientDefaultProminent, .aiCoGradientDefaultLight]
            case .accent:
                return [.aiCoGradientAccentLight, .aiCoGradientAccentProminent, .aiCoGradientAccentLight]
            }
        }
    }
    
    static func aiCoGradientStyle(_ style: AICoGradientStyle) -> Gradient {
        Gradient(colors: style.colors)
    }
}
