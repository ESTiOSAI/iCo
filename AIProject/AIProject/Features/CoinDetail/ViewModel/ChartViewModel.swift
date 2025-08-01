//
//  CoinChartViewModel.swift
//  AIProject
//
//  Created by 강민지 on 8/1/25.
//

import SwiftUI

@MainActor
final class ChartViewModel: ObservableObject {
    @Published var name: String = "비트코인"
    @Published var symbol: String = "BTC"
    @Published var currency: String = "USD"
    
    @Published var prices: [CoinPrice] = []
    
    init() {
        // 최초 진입 시 1D 구간 더미 데이터
        self.prices = Self.makeDummyPrices(hours: 24, samplingInterval: 60)
    }
    
    var summary: PriceSummary? {
        guard let first = prices.first, let last = prices.last else { return nil }
        let change = last.close - first.close
        let changeRate = first.close == 0 ? 0 : (change / first.close) * 100
        return .init(lastPrice: last.close, change: change, changeRate: changeRate)
    }
}

extension ChartViewModel {
    static func makeDummyPrices(hours: Double, samplingInterval: TimeInterval) -> [CoinPrice] {
        let now = Date()
        let startDate = now.addingTimeInterval(-hours * 3600)
        let sampleCount = Int((hours * 3600) / samplingInterval)
        
        var priceSeries: [CoinPrice] = []
        var currentTimestamp = startDate
        var value = 100.0
        
        for _ in 0..<sampleCount {
            priceSeries.append(.init(date: currentTimestamp, close: value))
            currentTimestamp = currentTimestamp.addingTimeInterval(samplingInterval)
        }
        return priceSeries
    }
}
