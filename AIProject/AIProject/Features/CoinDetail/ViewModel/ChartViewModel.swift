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
    @Published var coinName: String = "비트코인"
    /// 심볼 (예: "BTC")
    @Published var coinSymbol: String = "BTC"
    /// 통화 코드 (예: "USD")
    @Published var currency: String = "USD"
    
    /// 차트에 바인딩되는 시계열 가격 데이터
    @Published var prices: [CoinPrice] = []
    
    /// 가격 데이터를 가져오는 서비스
    private let priceService: CoinPriceProvider
    /// 차트 가격 데이터를 주기적으로 갱신하기 위한 타이머
    private var timer: Timer?
    
    /// 초기 진입 시 1일(1D) 범위의 더미 시계열 데이터를 준비
    init(priceService: CoinPriceProvider = UpbitPriceService()) {
        self.priceService = priceService
        startUpdating()
    }
    
    /// 주기적으로 가격 데이터를 불러오는 갱신 루프를 시작
    /// - Note: 최초 1회 실행 후 60초마다 반복 호출
    private func startUpdating() {
        // 최초 1회
        Task { await loadPrices() }

        // 이후 1분마다 반복
        timer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { _ in
            Task { await self.loadPrices() }
        }
    }
    
    /// 타이머 종료 및 메모리 정리
    deinit {
        timer?.invalidate()
        timer = nil
    }
    
    
    /// API로부터 실시간 가격 데이터를 불러와 시계열 배열로 갱신함
    /// - Parameter interval: 차트 간격 (기본: 1일)
    func loadPrices(interval: CoinInterval = .d1) async {
        do {
            let marketCode = "KRW-\(coinSymbol)"
            let fetchedPrices = try await priceService.fetchPrices(market: marketCode, interval: interval)
            self.prices = fetchedPrices
        } catch {
            print("가격 불러오기 실패: \(error.localizedDescription)")
            self.prices = []
        }
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
