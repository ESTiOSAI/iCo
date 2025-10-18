//
//  AppFont.swift
//  iCo
//
//  Created by 백현진 on 10/14/25.
//

import SwiftUI

struct AppFont {
    /// 시스템 다이내믹 타입 설정에 따라 자동으로 크기가 조정되는 폰트를 반환합니다.
    /// 폰트 두께(weight)와 접근성 글자 크기 설정을 모두 지원하며,
    /// 과도한 라인 높이(line height) 증가를 자동으로 보정합니다.
    /// - Parameters:
    ///   - targetSize: 기본 폰트 크기(pt)
    ///   - weight: 폰트 두께 (예: .regular, .bold 등)
    ///   - textStyle: 다이내믹 타입 기준 스타일 (기본값: .body)
    ///   - maxLineHeightScale: 라인 높이 확장 제한 비율 (기본값: 1.8)
    static func dynamic(
        size targetSize: CGFloat,
        weight: UIFont.Weight = .regular,
        textStyle: UIFont.TextStyle = .body,
        maxLineHeightScale: CGFloat = 1.8
    ) -> Font {
        let baseFont = UIFont.systemFont(ofSize: targetSize, weight: weight)
        
        let scaledFont = UIFontMetrics(forTextStyle: textStyle).scaledFont(for: baseFont)
        
        // 폰트가 너무 커졌을 경우, 기본 대비 maxLineHeightScale까지만 확장
        let scaleRatio = scaledFont.pointSize / baseFont.pointSize
        let clampedScale = min(scaleRatio, maxLineHeightScale)
        let adjustedFont = baseFont.withSize(baseFont.pointSize * clampedScale)
        
        return Font(adjustedFont)
    }
}
