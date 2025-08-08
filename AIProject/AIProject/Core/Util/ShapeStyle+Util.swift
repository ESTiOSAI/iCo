//
//  ShapeStyle+Util.swift
//  AIProject
//
//  Created by Kitcat Seo on 8/7/25.
//

import SwiftUI

/// 버튼 등 공통 UI 요소에 사용할 stroke 스타일을 정의한 LinearGradient 확장
extension ShapeStyle where Self == LinearGradient {
    static var `default`: LinearGradient {
        LinearGradient(
            gradient: Gradient.aiCoGradientStyle(.default),
            startPoint: .leading,
            endPoint: .trailing
        )
    }
    
    static var accent: LinearGradient {
        LinearGradient(
            gradient: Gradient.aiCoGradientStyle(.accent),
            startPoint: .leading,
            endPoint: .trailing
        )
    }
}
