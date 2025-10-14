//
//  AppFont.swift
//  iCo
//
//  Created by 백현진 on 10/14/25.
//

import SwiftUI


struct AppFont {
    /// 시스템 다이내믹 폰트 크기에 따라 자동으로 크기가 조정되는 폰트를 반환합니다.
    /// 기본 폰트는 iOS 시스템 폰트인 "SF Pro Text"이며, 비율에 따라 targetSize 크기로 스케일됩니다.
    /// - Parameters:
    ///   - targetSize: 기준이 되는 폰트 크기(pt)입니다. (예: 17)
    ///   - weight: 폰트 두께를 지정합니다. 기본값은 `.regular`입니다.
    ///   - relativeTo: 다이내믹 타입 기준이 되는 텍스트 스타일입니다. 기본값은 `.body`입니다.
    static func dynamic(
        size targetSize: CGFloat,
        weight: Font.Weight = .regular,
        relativeTo: Font.TextStyle = .body
    ) -> Font {
        let baseSize: CGFloat = 17
        let ratio = targetSize / baseSize
        let scaledSize = baseSize * ratio

        return .custom("SF Pro Text", size: scaledSize, relativeTo: relativeTo)
            .weight(weight)
    }
}
