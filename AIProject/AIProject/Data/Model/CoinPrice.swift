//
//  CoinPrice.swift
//  AIProject
//
//  Created by 강민지 on 7/31/25.
//

import Foundation

/// 코인 가격의 한 지점(시계열) 표현
struct CoinPrice: Identifiable {
    /// 데이터 시점 (차트 x축)
    let date: Date
    /// 해당 시점의 종가 (차트 y축)
    let close: Double
    /// `date` 기반 고유 식별자
    var id: TimeInterval { date.timeIntervalSinceReferenceDate }
}

/// 차트 상단 표시에 사용하는 가격 요약 값
struct PriceSummary {
    /// 구간의 마지막 가격
    let lastPrice: Double
    /// 첫 가격 대비 절대 변화량 (마지막 ~ 첫)
    let change: Double
    /// 첫 가격 대비 등락률 (%)
    let changeRate: Double
}
