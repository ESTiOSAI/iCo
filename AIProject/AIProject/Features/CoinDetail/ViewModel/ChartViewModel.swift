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
        self.isBookmarked = (try? BookmarkManager.shared.isBookmarked(coinSymbol)) ?? false
    }
    
    /// 현재 코인의 북마크 상태를 토글하고, 결과를 isBookmarked에 반영
    func toggleBookmark() {
        if let result = try? BookmarkManager.shared.toggle(coinID: coinSymbol, coinKoreanName: coinName) {
            self.isBookmarked = result
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
    func loadPrices(interval: CoinInterval = .all.first!) async {
        do {
            let marketCode = coinSymbol
            let fetchedPrices = try await priceService.fetchPrices(market: marketCode, interval: interval)
            
            /// KST 기준으로 오늘의 시작 시간과 현재 시각 계산
            var calendar = Calendar.current
            calendar.timeZone = TimeZone(identifier: "Asia/Seoul")!

            let nowKST = Date()
            let todayStartKST = calendar.startOfDay(for: nowKST)

            /// 당일 범위에 해당하는 가격만 필터링
            let filteredPrices = fetchedPrices.filter { price in
                return price.date >= todayStartKST && price.date <= nowKST
            }
                        
            self.prices = filteredPrices.enumerated().map { idx, price in
                CoinPrice(
                    date: price.date,
                    open: price.open,
                    high: price.high,
                    low: price.low,
                    close: price.close,
                    tradeValue: price.tradeValue,
                    index: idx
                )
            }
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

extension ChartViewModel {
    /// Y축 범위 설정
    /// - Parameters:
    ///   - data: 표시할 가격 데이터 배열
    /// - Returns: Y축의 최소/최대값을 포함한 범위 (패딩 포함)
    /// - Note: 최소 범위는 10 이상이며, 여유 공간을 위해 ±20% 패딩을 추가
    func yAxisRange(from data: [CoinPrice]) -> ClosedRange<Double> {
        let minY = data.map(\.low).min() ?? 0
        let maxY = data.map(\.high).max() ?? 0
        let range = maxY - minY
        let safeRange = max(range, 10)
        let padding = range * 0.2
        let center = (minY + maxY) / 2
        return (center - safeRange / 2 - padding)...(center + safeRange / 2 + padding)
    }
    
    /// X축의 시간 범위(Domain)를 계산
    /// - Parameters:
    ///   - data: 시각화할 가격 데이터 배열
    /// - Returns: 당일 자정부터 현재(마지막 데이터)까지의 시점이며, 여유 공간을 위한 현재 시점 +5분까지의 시간 범위 추가
    func xAxisDomain(for data: [CoinPrice]) -> ClosedRange<Date> {
        let now = Date()
        let calendar = Calendar(identifier: .gregorian)
        let lastDate = data.last?.date ?? now
        let xStart = calendar.startOfDay(for: now)
        let xEnd = lastDate.addingTimeInterval(60 * 5)
        return xStart...xEnd
    }
    
    /// 초기 차트 스크롤 위치를 지정할 시각을 반환
    /// - Parameters:
    ///   - data: 시각화할 가격 데이터 배열
    /// - Returns: 마지막 데이터 시점 +5분
    func scrollToTime(for data: [CoinPrice]) -> Date {
        data.last?.date.addingTimeInterval(60 * 5) ?? Date()
    }
    
    /// 차트 X축 라벨에 사용할 시간 포맷터 (24시간제 HH:mm 형식)
    /// - Returns: "HH:mm" 포맷을 사용하는 DateFormatter (ko_KR 로케일)
    var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter
    }
}
