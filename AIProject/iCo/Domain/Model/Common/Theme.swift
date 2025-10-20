//
//  Theme.swift
//  AIProject
//
//  Created by 강민지 on 8/8/25.
//

import SwiftUI

/// 앱에서 사용 가능한 테마 유형
enum Theme: String, CaseIterable {
    case basic
    case pop
    case classic
    
    /// 선택된 테마에 대응하는 상승 색상
    var positiveColor: Color {
        switch self {
        case .basic: return .iCoPositive
        case .pop: return .iCoPositivePop
        case .classic: return .iCoPositiveClassic
        }
    }
    
    /// 선택된 테마에 대응하는 하락 색상
    var negativeColor: Color {
        switch self {
        case .basic: return .iCoNegative
        case .pop: return .iCoNegativePop
        case .classic: return .iCoNegativeClassic
        }
    }
    
    var neutral: Color { .iCoNeutral }
}

extension Theme {
    var displayName: String {
        switch self {
        case .basic: return "기본"
        case .pop: return "팝"
        case .classic: return "고전"
        }
    }
}
