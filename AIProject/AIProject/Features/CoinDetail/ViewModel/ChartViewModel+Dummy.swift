//
//  ChartViewModel+Dummy.swift
//  AIProject
//
//  Created by 강민지 on 8/7/25.
//

import Foundation

// MARK: - Dummy Data Generator
extension ChartViewModel {
    /// 지정한 시간 범위와 샘플링 간격으로 더미 시계열 가격을 생성
    /// - Parameters:
    ///   - hours: 과거로부터 생성할 시간 범위 (시간 단위, 예: 24)
    ///   - samplingInterval: 샘플 간격 (초, 예: 60 → 1분)
    /// - Returns: 생성된 `CoinPrice` 시계열 배열
    static func makeDummyPrices(hours: Double, samplingInterval: TimeInterval) -> [CoinPrice] {
        let now = Date()
        let startDate = now.addingTimeInterval(-hours * 3600)
        let sampleCount = Int((hours * 3600) / samplingInterval)
        
        var priceSeries: [CoinPrice] = []
        var currentTimestamp = startDate
        var value = 100.0
        
        for i in 0..<sampleCount {
            let open = value
            let close = value + Double.random(in: -2...2)
            let high = max(open, close) + Double.random(in: 0...1)
            let low = min(open, close) - Double.random(in: 0...1)
            let tradeValue = Double.random(in: 50_000_000...200_000_000)
            
            priceSeries.append(
                CoinPrice(
                    date: currentTimestamp,
                    open: open,
                    high: high,
                    low: low,
                    close: close,
                    trade: tradeValue,
                    index: i
                )
            )
            
            currentTimestamp = currentTimestamp.addingTimeInterval(samplingInterval)
            value = close
        }
        return priceSeries
    }
}
