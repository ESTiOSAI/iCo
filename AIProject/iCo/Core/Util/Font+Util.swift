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
    static var ico10   = Font.dynamic(size: 10, weight: .regular)
    static var ico10L  = Font.dynamic(size: 10, weight: .light)
    static var ico10M  = Font.dynamic(size: 10, weight: .medium)
    static var ico10Sb = Font.dynamic(size: 10, weight: .semibold)
    static var ico10B  = Font.dynamic(size: 10, weight: .bold)
    static var ico10H  = Font.dynamic(size: 10, weight: .heavy)
    static var ico10Bl = Font.dynamic(size: 10, weight: .black)
    
    // 11pt
    static var ico11   = Font.dynamic(size: 11, weight: .regular)
    static var ico11L  = Font.dynamic(size: 11, weight: .light)
    static var ico11M  = Font.dynamic(size: 11, weight: .medium)
    static var ico11Sb = Font.dynamic(size: 11, weight: .semibold)
    static var ico11B  = Font.dynamic(size: 11, weight: .bold)
    static var ico11H  = Font.dynamic(size: 11, weight: .heavy)
    static var ico11Bl = Font.dynamic(size: 11, weight: .black)
    
    // 12pt
    static var ico12   = Font.dynamic(size: 12, weight: .regular)
    static var ico12L  = Font.dynamic(size: 12, weight: .light)
    static var ico12M  = Font.dynamic(size: 12, weight: .medium)
    static var ico12Sb = Font.dynamic(size: 12, weight: .semibold)
    static var ico12B  = Font.dynamic(size: 12, weight: .bold)
    static var ico12H  = Font.dynamic(size: 12, weight: .heavy)
    static var ico12Bl = Font.dynamic(size: 12, weight: .black)
    
    // 13pt
    static var ico13   = Font.dynamic(size: 13, weight: .regular)
    static var ico13L  = Font.dynamic(size: 13, weight: .light)
    static var ico13M  = Font.dynamic(size: 13, weight: .medium)
    static var ico13Sb = Font.dynamic(size: 13, weight: .semibold)
    static var ico13B  = Font.dynamic(size: 13, weight: .bold)
    static var ico13H  = Font.dynamic(size: 13, weight: .heavy)
    static var ico13Bl = Font.dynamic(size: 13, weight: .black)
    
    // 14pt
    static var ico14   = Font.dynamic(size: 14, weight: .regular)
    static var ico14L  = Font.dynamic(size: 14, weight: .light)
    static var ico14M  = Font.dynamic(size: 14, weight: .medium)
    static var ico14Sb = Font.dynamic(size: 14, weight: .semibold)
    static var ico14B  = Font.dynamic(size: 14, weight: .bold)
    static var ico14H  = Font.dynamic(size: 14, weight: .heavy)
    static var ico14Bl = Font.dynamic(size: 14, weight: .black)
    
    // 15pt
    static var ico15   = Font.dynamic(size: 15, weight: .regular)
    static var ico15L  = Font.dynamic(size: 15, weight: .light)
    static var ico15M  = Font.dynamic(size: 15, weight: .medium)
    static var ico15Sb = Font.dynamic(size: 15, weight: .semibold)
    static var ico15B  = Font.dynamic(size: 15, weight: .bold)
    static var ico15H  = Font.dynamic(size: 15, weight: .heavy)
    static var ico15Bl = Font.dynamic(size: 15, weight: .black)
    
    // 16pt
    static var ico16   = Font.dynamic(size: 16, weight: .regular)
    static var ico16L  = Font.dynamic(size: 16, weight: .light)
    static var ico16M  = Font.dynamic(size: 16, weight: .medium)
    static var ico16Sb = Font.dynamic(size: 16, weight: .semibold)
    static var ico16B  = Font.dynamic(size: 16, weight: .bold)
    static var ico16H  = Font.dynamic(size: 16, weight: .heavy)
    static var ico16Bl = Font.dynamic(size: 16, weight: .black)
    
    // 17pt
    static var ico17   = Font.dynamic(size: 17, weight: .regular)
    static var ico17L  = Font.dynamic(size: 17, weight: .light)
    static var ico17M  = Font.dynamic(size: 17, weight: .medium)
    static var ico17Sb = Font.dynamic(size: 17, weight: .semibold)
    static var ico17B  = Font.dynamic(size: 17, weight: .bold)
    static var ico17H  = Font.dynamic(size: 17, weight: .heavy)
    static var ico17Bl = Font.dynamic(size: 17, weight: .black)
    
    // 18pt
    static var ico18   = Font.dynamic(size: 18, weight: .regular)
    static var ico18L  = Font.dynamic(size: 18, weight: .light)
    static var ico18M  = Font.dynamic(size: 18, weight: .medium)
    static var ico18Sb = Font.dynamic(size: 18, weight: .semibold)
    static var ico18B  = Font.dynamic(size: 18, weight: .bold)
    static var ico18H  = Font.dynamic(size: 18, weight: .heavy)
    static var ico18Bl = Font.dynamic(size: 18, weight: .black)
    
    // 19pt
    static var ico19   = Font.dynamic(size: 19, weight: .regular)
    static var ico19L  = Font.dynamic(size: 19, weight: .light)
    static var ico19M  = Font.dynamic(size: 19, weight: .medium)
    static var ico19Sb = Font.dynamic(size: 19, weight: .semibold)
    static var ico19B  = Font.dynamic(size: 19, weight: .bold)
    static var ico19H  = Font.dynamic(size: 19, weight: .heavy)
    static var ico19Bl = Font.dynamic(size: 19, weight: .black)
    
    // 20pt
    static var ico20   = Font.dynamic(size: 20, weight: .regular)
    static var ico20L  = Font.dynamic(size: 20, weight: .light)
    static var ico20M  = Font.dynamic(size: 20, weight: .medium)
    static var ico20Sb = Font.dynamic(size: 20, weight: .semibold)
    static var ico20B  = Font.dynamic(size: 20, weight: .bold)
    static var ico20H  = Font.dynamic(size: 20, weight: .heavy)
    static var ico20Bl = Font.dynamic(size: 20, weight: .black)
    
    // 21pt
    static var ico21   = Font.dynamic(size: 21, weight: .regular)
    static var ico21L  = Font.dynamic(size: 21, weight: .light)
    static var ico21M  = Font.dynamic(size: 21, weight: .medium)
    static var ico21Sb = Font.dynamic(size: 21, weight: .semibold)
    static var ico21B  = Font.dynamic(size: 21, weight: .bold)
    static var ico21H  = Font.dynamic(size: 21, weight: .heavy)
    static var ico21Bl = Font.dynamic(size: 21, weight: .black)
    
    // 24pt
    static var ico24   = Font.dynamic(size: 24, weight: .regular)
    static var ico24L  = Font.dynamic(size: 24, weight: .light)
    static var ico24M  = Font.dynamic(size: 24, weight: .medium)
    static var ico24Sb = Font.dynamic(size: 24, weight: .semibold)
    static var ico24B  = Font.dynamic(size: 24, weight: .bold)
    static var ico24H  = Font.dynamic(size: 24, weight: .heavy)
    static var ico24Bl = Font.dynamic(size: 24, weight: .black)
    
    // 35pt
    static var ico35   = Font.dynamic(size: 35, weight: .regular)
    static var ico35L  = Font.dynamic(size: 35, weight: .light)
    static var ico35M  = Font.dynamic(size: 35, weight: .medium)
    static var ico35Sb = Font.dynamic(size: 35, weight: .semibold)
    static var ico35B  = Font.dynamic(size: 35, weight: .bold)
    static var ico35H  = Font.dynamic(size: 35, weight: .heavy)
    static var ico35Bl = Font.dynamic(size: 35, weight: .black)
}
