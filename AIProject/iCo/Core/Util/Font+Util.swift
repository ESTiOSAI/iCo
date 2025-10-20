//
//  Font+Util.swift
//  iCo
//
//  Created by 백현진 on 10/14/25.
//

import SwiftUI

extension Font {
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
    
    // 10pt
    static let ico10   = Font.dynamic(size: 10, weight: .regular)
    static let ico10L  = Font.dynamic(size: 10, weight: .light)
    static let ico10M  = Font.dynamic(size: 10, weight: .medium)
    static let ico10Sb = Font.dynamic(size: 10, weight: .semibold)
    static let ico10B  = Font.dynamic(size: 10, weight: .bold)
    static let ico10H  = Font.dynamic(size: 10, weight: .heavy)
    static let ico10Bl = Font.dynamic(size: 10, weight: .black)
    
    // 11pt
    static let ico11   = Font.dynamic(size: 11, weight: .regular)
    static let ico11L  = Font.dynamic(size: 11, weight: .light)
    static let ico11M  = Font.dynamic(size: 11, weight: .medium)
    static let ico11Sb = Font.dynamic(size: 11, weight: .semibold)
    static let ico11B  = Font.dynamic(size: 11, weight: .bold)
    static let ico11H  = Font.dynamic(size: 11, weight: .heavy)
    static let ico11Bl = Font.dynamic(size: 11, weight: .black)
    
    // 12pt
    static let ico12   = Font.dynamic(size: 12, weight: .regular)
    static let ico12L  = Font.dynamic(size: 12, weight: .light)
    static let ico12M  = Font.dynamic(size: 12, weight: .medium)
    static let ico12Sb = Font.dynamic(size: 12, weight: .semibold)
    static let ico12B  = Font.dynamic(size: 12, weight: .bold)
    static let ico12H  = Font.dynamic(size: 12, weight: .heavy)
    static let ico12Bl = Font.dynamic(size: 12, weight: .black)
    
    // 13pt
    static let ico13   = Font.dynamic(size: 13, weight: .regular)
    static let ico13L  = Font.dynamic(size: 13, weight: .light)
    static let ico13M  = Font.dynamic(size: 13, weight: .medium)
    static let ico13Sb = Font.dynamic(size: 13, weight: .semibold)
    static let ico13B  = Font.dynamic(size: 13, weight: .bold)
    static let ico13H  = Font.dynamic(size: 13, weight: .heavy)
    static let ico13Bl = Font.dynamic(size: 13, weight: .black)
    
    // 14pt
    static let ico14   = Font.dynamic(size: 14, weight: .regular)
    static let ico14L  = Font.dynamic(size: 14, weight: .light)
    static let ico14M  = Font.dynamic(size: 14, weight: .medium)
    static let ico14Sb = Font.dynamic(size: 14, weight: .semibold)
    static let ico14B  = Font.dynamic(size: 14, weight: .bold)
    static let ico14H  = Font.dynamic(size: 14, weight: .heavy)
    static let ico14Bl = Font.dynamic(size: 14, weight: .black)
    
    // 15pt
    static let ico15   = Font.dynamic(size: 15, weight: .regular)
    static let ico15L  = Font.dynamic(size: 15, weight: .light)
    static let ico15M  = Font.dynamic(size: 15, weight: .medium)
    static let ico15Sb = Font.dynamic(size: 15, weight: .semibold)
    static let ico15B  = Font.dynamic(size: 15, weight: .bold)
    static let ico15H  = Font.dynamic(size: 15, weight: .heavy)
    static let ico15Bl = Font.dynamic(size: 15, weight: .black)
    
    // 16pt
    static let ico16   = Font.dynamic(size: 16, weight: .regular)
    static let ico16L  = Font.dynamic(size: 16, weight: .light)
    static let ico16M  = Font.dynamic(size: 16, weight: .medium)
    static let ico16Sb = Font.dynamic(size: 16, weight: .semibold)
    static let ico16B  = Font.dynamic(size: 16, weight: .bold)
    static let ico16H  = Font.dynamic(size: 16, weight: .heavy)
    static let ico16Bl = Font.dynamic(size: 16, weight: .black)
    
    // 17pt
    static let ico17   = Font.dynamic(size: 17, weight: .regular)
    static let ico17L  = Font.dynamic(size: 17, weight: .light)
    static let ico17M  = Font.dynamic(size: 17, weight: .medium)
    static let ico17Sb = Font.dynamic(size: 17, weight: .semibold)
    static let ico17B  = Font.dynamic(size: 17, weight: .bold)
    static let ico17H  = Font.dynamic(size: 17, weight: .heavy)
    static let ico17Bl = Font.dynamic(size: 17, weight: .black)
    
    // 18pt
    static let ico18   = Font.dynamic(size: 18, weight: .regular)
    static let ico18L  = Font.dynamic(size: 18, weight: .light)
    static let ico18M  = Font.dynamic(size: 18, weight: .medium)
    static let ico18Sb = Font.dynamic(size: 18, weight: .semibold)
    static let ico18B  = Font.dynamic(size: 18, weight: .bold)
    static let ico18H  = Font.dynamic(size: 18, weight: .heavy)
    static let ico18Bl = Font.dynamic(size: 18, weight: .black)
    
    // 19pt
    static let ico19   = Font.dynamic(size: 19, weight: .regular)
    static let ico19L  = Font.dynamic(size: 19, weight: .light)
    static let ico19M  = Font.dynamic(size: 19, weight: .medium)
    static let ico19Sb = Font.dynamic(size: 19, weight: .semibold)
    static let ico19B  = Font.dynamic(size: 19, weight: .bold)
    static let ico19H  = Font.dynamic(size: 19, weight: .heavy)
    static let ico19Bl = Font.dynamic(size: 19, weight: .black)
    
    // 20pt
    static let ico20   = Font.dynamic(size: 20, weight: .regular)
    static let ico20L  = Font.dynamic(size: 20, weight: .light)
    static let ico20M  = Font.dynamic(size: 20, weight: .medium)
    static let ico20Sb = Font.dynamic(size: 20, weight: .semibold)
    static let ico20B  = Font.dynamic(size: 20, weight: .bold)
    static let ico20H  = Font.dynamic(size: 20, weight: .heavy)
    static let ico20Bl = Font.dynamic(size: 20, weight: .black)
    
    // 24pt
    static let ico24   = Font.dynamic(size: 24, weight: .regular)
    static let ico24L  = Font.dynamic(size: 24, weight: .light)
    static let ico24M  = Font.dynamic(size: 24, weight: .medium)
    static let ico24Sb = Font.dynamic(size: 24, weight: .semibold)
    static let ico24B  = Font.dynamic(size: 24, weight: .bold)
    static let ico24H  = Font.dynamic(size: 24, weight: .heavy)
    static let ico24Bl = Font.dynamic(size: 24, weight: .black)
    
    // 35pt
    static let ico35   = Font.dynamic(size: 35, weight: .regular)
    static let ico35L  = Font.dynamic(size: 35, weight: .light)
    static let ico35M  = Font.dynamic(size: 35, weight: .medium)
    static let ico35Sb = Font.dynamic(size: 35, weight: .semibold)
    static let ico35B  = Font.dynamic(size: 35, weight: .bold)
    static let ico35H  = Font.dynamic(size: 35, weight: .heavy)
    static let ico35Bl = Font.dynamic(size: 35, weight: .black)
}
