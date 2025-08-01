//
//  CoinPrice.swift
//  AIProject
//
//  Created by 강민지 on 7/31/25.
//

import Foundation

struct CoinPrice: Identifiable {
    let date: Date          // 시점(x축)
    let close: Double       // 종가(y축)
    var id: TimeInterval { date.timeIntervalSinceReferenceDate }
}

struct PriceSummary {
    let lastPrice: Double   // 마지막 가격
    let change: Double      // 첫~끝 차이
    let changeRate: Double  // 등락률(%)
}
