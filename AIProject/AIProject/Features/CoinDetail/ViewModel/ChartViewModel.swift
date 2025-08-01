//
//  CoinChartViewModel.swift
//  AIProject
//
//  Created by 강민지 on 8/1/25.
//

import SwiftUI

/// 코인 차트 화면의 상태를 관리하는 ViewModel
@MainActor
final class ChartViewModel: ObservableObject {
    /// 코인 표시 이름 (예: "비트코인")
    @Published var name: String = "비트코인"
    /// 심볼 (예: "BTC")
    @Published var symbol: String = "BTC"
    /// 통화 코드 (예: "USD")
    @Published var currency: String = "USD"
    
    /// 차트에 바인딩되는 시계열 가격 데이터
    @Published var prices: [CoinPrice] = []
    
    /// 초기 진입 시 1일(1D) 범위의 더미 시계열 데이터를 준비
    init() {
        self.prices = Self.makeDummyPrices(hours: 24, samplingInterval: 60)
    }
    
    /// 현재 `prices` 기준의 간단한 요약 정보
    /// 마지막 가격, 절대 변화량, 등락률 (%)을 계산해 반환
    var summary: PriceSummary? {
        guard let first = prices.first, let last = prices.last else { return nil }
        let change = last.close - first.close
        let changeRate = first.close == 0 ? 0 : (change / first.close) * 100
        return .init(lastPrice: last.close, change: change, changeRate: changeRate)
    }
}

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
        
        for _ in 0..<sampleCount {
            priceSeries.append(.init(date: currentTimestamp, close: value))
            currentTimestamp = currentTimestamp.addingTimeInterval(samplingInterval)
        }
        return priceSeries
    }
}
