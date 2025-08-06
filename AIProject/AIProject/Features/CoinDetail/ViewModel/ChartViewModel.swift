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
    @Published var coinName: String
    /// 심볼 (예: "KRW-BTC")
    @Published var coinSymbol: String
    /// 통화 코드 (예: "USD")
    @Published var currency: String
    /// 현재 코인이 북마크된 상태인지 나타냄
    @Published var isBookmarked: Bool = false
    /// 차트에 바인딩되는 시계열 가격 데이터
    @Published var prices: [CoinPrice] = []
    
    /// 가격 데이터를 가져오는 서비스
    private let priceService: CoinPriceProvider
    
    /// 주기적 업데이트 태스크 (취소를 위해 저장)
    private var updateTask: Task<Void, Never>?
    
    init(coin: Coin, priceService: CoinPriceProvider = UpbitPriceService()) {
        self.coinName = coin.koreanName
        self.coinSymbol = coin.id
        // id: "KRW-BTC" → currency: "KRW"
        self.currency = coin.id.split(separator: "-").first.map(String.init) ?? "KRW"
        self.priceService = priceService
        startUpdating()
    }
    
    /// 현재 코인이 북마크되어 있는지 확인하여 isBookmarked 상태를 갱신
    func checkBookmark() {
        Task {
            self.isBookmarked = (try? BookmarkManager.shared.isBookmarked(coinSymbol)) ?? false
        }
    }

    /// 현재 코인의 북마크 상태를 토글하고, 결과를 isBookmarked에 반영
    func toggleBookmark() {
        Task {
            if let result = try? BookmarkManager.shared.toggle(coinID: coinSymbol) {
                self.isBookmarked = result
                print("[북마크 상태] \(result ? "추가됨" : "제거됨")")
            }
        }
    }
    
    /// 주기적으로 가격 데이터를 불러오는 갱신 루프를 시작
    /// - Note: 최초 1회 실행 후 60초마다 반복 호출
    private func startUpdating() {
        updateTask = Task {
            await loadPrices()
            while true {
                try? await Task.sleep(nanoseconds: 60 * 1_000_000_000)
                await loadPrices()
            }
        }
    }
    
    /// 타이머 종료 및 메모리 정리
    deinit {
        updateTask?.cancel()
    }
    
    
    /// API로부터 실시간 가격 데이터를 불러와 시계열 배열로 갱신함
    /// - Parameter interval: 차트 간격 (기본: 1일)
    func loadPrices(interval: CoinInterval = .d1) async {
        do {
            let marketCode = coinSymbol
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
