//
//  CoinInterval.swift
//  AIProject
//
//  Created by 강민지 on 8/1/25.
//

import Foundation

/// 코인 차트의 기간 선택 옵션
/// `rawValue`는 UI 표시용 문자열 (예: "1D") 이며, `Identifiable`의 `id`로도 재사용
enum CoinInterval: String, CaseIterable, Identifiable {
    /// 1일
    case d1 = "1D"
    /// 1주
    case w1 = "1W"
    /// 3개월
    case m3 = "3M"
    /// 6개월
    case m6 = "6M"
    /// 1년
    case y1 = "1Y"
    
    /// UI 및 리스트 바인딩을 위한 고유 식별자
    var id: String { rawValue }
}
