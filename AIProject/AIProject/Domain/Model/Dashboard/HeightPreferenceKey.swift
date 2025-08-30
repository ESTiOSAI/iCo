//
//  HeightPreferenceKey.swift
//  AIProject
//
//  Created by 장지현 on 8/30/25.
//

import SwiftUI

/// 뷰의 높이를 측정하고 부모 뷰로 전달하기 위한 `PreferenceKey`입니다.
///
/// 여러 자식 뷰에서 보고된 높이 값 중 최대값을 유지하도록 동작합니다.
/// 레이아웃 계산 시, 자식 뷰들의 높이를 비교하여 가장 큰 값을 부모 뷰에 전달하는 데 사용됩니다.
struct HeightPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}
