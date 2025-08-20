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
    
    /// Header 데이터 (Ticker 기반 지표)
    /// 현재가
    @Published private(set) var headerLastPrice: Double = 0
    /// 전일 대비 절대 변화량 (부호 포함)
    @Published private(set) var headerChangePrice: Double = 0
    /// 전일 대비 등락률(%)
    @Published private(set) var headerChangeRate: Double = 0
    /// 당일 누적 거래대금
    @Published private(set) var headerAccTradePrice: Double = 0
    
    /// 최근 데이터 기준 시각 (헤더 'yyyy.MM.dd HH:mm 기준'에 사용)
    @Published private(set) var lastUpdated: Date? = nil

    /// 취소/재시도 버튼을 실제 동작(네트워크 취소, 주기 루프 중단/재개)에 연결하는 상태 허브 (공용 컴포넌트 DefaultProgressView/StatusSwitch 연동)
    @Published private(set) var status: ResponseStatus = .loading
    
    /// 가격 데이터를 가져오는 서비스
    private let priceService: CoinPriceProvider
    
    /// 주기적 업데이트 태스크 (취소를 위해 저장)
    private var updateTask: Task<Void, Never>?
    
    init(coin: Coin, priceService: CoinPriceProvider = UpbitPriceService()) {
        self.coinName = coin.koreanName
        self.coinSymbol = coin.id
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
        updateTask?.cancel() // 중복 시작 방지
        
        updateTask = Task { [weak self] in
            await self?.loadPrices() // 최초 1회
            
            while !Task.isCancelled {
                _ = try? await Task.sleep(nanoseconds: 60 * 1_000_000_000)
                
                if Task.isCancelled { break } // 취소 시 즉시 종료
                
                await self?.loadPrices()
            }
        }
    }
    
    /// 네트워크/루프 중단
    func stopUpdating() {
        updateTask?.cancel()
        updateTask = nil
    }
    
    /// 사용자 취소에 의해 화면 상태를 `.cancel(.taskCancelled)`로 갱신
    func cancelLoading() {
        stopUpdating()
        status = .cancel(.taskCancelled)
    }

    /// 사용자의 '다시 시도' 선택에 재시도 (루프 재가동)
    func retry() {
        startUpdating()
    }
    
    /// 타이머 종료 및 메모리 정리
    deinit {
        print(String(describing: Self.self) + " deinit")
        updateTask?.cancel()
    }
    
    /// API로부터 실시간 가격 데이터를 불러와 시계열 배열로 갱신함
    /// - Parameter interval: 차트 간격 (기본: 1일)
    func loadPrices(interval: CoinInterval = .all.first!) async {
        /// 로딩 상태 진입 (초기/재시도 시 ProgressView와 동기화)
        status = .loading
        
        do {
            let marketCode = coinSymbol
            
            /// - 분봉(차트용): 캔들 렌더링에 사용
            /// - Ticker(헤더용): 전일 대비/누적 거래대금 등 헤더 지표(목록 화면과 동일 정의)에 사용
            async let pricesTask: [CoinPrice] = priceService.fetchPrices(market: marketCode, interval: interval)
            async let tickerTask = UpBitAPIService().fetchTicker(by: currency)

            let (fetchedPrices, tickers) = try await (pricesTask, tickerTask)
            try Task.checkCancellation()  
            let ticker = tickers.first { $0.id == marketCode }
                                    
            let now = Date()
            let startTime = now.addingTimeInterval(-24 * 60 * 60)

            /// 당일 범위에 해당하는 가격만 필터링
            let filteredPrices = fetchedPrices.filter { price in
                return price.date >= startTime && price.date <= now
            }
                        
            self.prices = filteredPrices.enumerated().map { idx, price in
                CoinPrice(
                    date: price.date,
                    open: price.open,
                    high: price.high,
                    low: price.low,
                    close: price.close,
                    trade: price.trade,
                    index: idx
                )
            }
            
            if let ticker = ticker {
                /// 현재가
                headerLastPrice = ticker.price
                /// 등락률: 서버는 비율로 주므로 % 표기 위해 *100
                let signedRate = (ticker.change == .fall) ? -ticker.rate : ticker.rate
                headerChangeRate = signedRate * 100
                
                /// 등락가(부호 포함): change(FALL/RISE/EVEN)으로 부호 적용
                if signedRate != 0 {
                    let prevClose = ticker.price / (1 + signedRate)
                    headerChangePrice = ticker.price - prevClose   // 부호 포함
                } else {
                    headerChangePrice = 0
                }
                
                /// 거래대금: 당일 누적을 사용 (코인 목록 화면과 동일).
                headerAccTradePrice = ticker.volume
            }
            
            /// 기준 시각 세팅: 우선 순위 (캔들 마지막 시각 사용)
            self.lastUpdated = filteredPrices.last?.date
            
            /// 성공 상태로 마무리 (데이터 유무는 뷰에서 처리)
            guard !Task.isCancelled else {
                status = .cancel(.taskCancelled)
                return
            }
            status = .success
        } catch is CancellationError {
            status = .cancel(.taskCancelled)
            return
        } catch NetworkError.taskCancelled {
            status = .cancel(.taskCancelled)
            return
        } catch {
            let err = (error as? NetworkError)
                ?? (error as? URLError).map(NetworkError.networkError)
                ?? .networkError(URLError(.unknown))
            #if DEBUG
            print("가격 불러오기 실패: \(err.log())")
            #endif
            status = .failure(err)
            
            /// 실패 시 기준 시각 초기화
            lastUpdated = nil
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
        let lastDate = data.last?.date ?? now
        let xStart = now.addingTimeInterval(-60 * 60 * 24)
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
