//
//  UpbitPriceService.swift
//  AIProject
//
//  Created by 강민지 on 8/1/25.
//

import Foundation

/// Upbit API로부터 가격 데이터를 받아와 `CoinPrice` 배열로 가공해 반환하는 서비스
///
/// 내부적으로 `UpBitAPIService`를 사용하며, 뷰모델에서는 이 추상화된 서비스를 통해 데이터를 조회
/// UpBitAPIService를 뷰모델에서 사용할 수 있도록 하는 어댑터 역할
final class UpbitPriceService: CoinPriceProvider {
    private let api: UpBitAPIService
    private let candleLimit = 200
    
    init(api: UpBitAPIService = .init()) {
        self.api = api
    }
    
    /// 지정된 마켓과 기간에 따라 시세 데이터를 반복 호출을 통해 수집하고 `CoinPrice` 배열로 반환
    /// - Parameters:
    ///   - market: 마켓 식별자 (예: "KRW-BTC")
    ///   - interval: 가져올 데이터의 기간 정보 (분 단위)
    ///   - to: 데이터를 가져올 종료 시점 (기본적으로 현재 시각 기준)
    /// - Returns: 변환된 `CoinPrice` 배열
    func fetchPrices(market: String, interval: CoinInterval, to: Date?) async throws -> [CoinPrice] {
        var allCandles: [MinuteCandleDTO] = []
        var toDate = interval.endDate
        
        while allCandles.count < interval.minutes {
            // 상위 Task 취소 시 여기서 즉시 CancellationError를 던져 다음 요청/반복을 막기 위함
            try Task.checkCancellation()
            
            let count = min(candleLimit, interval.minutes - allCandles.count)
            let newCandles = try await api.fetchCandles(id: market, count: count, to: toDate)
            
            guard !newCandles.isEmpty else { break }
            
            allCandles += newCandles
            toDate = newCandles.last!.tradeDateTime.addingTimeInterval(-60)  // 1분 이전으로 이동
        }
        
        return allCandles
            .reversed()
            .enumerated()
            .map { idx, dto in
                CoinPrice(
                    date: dto.tradeDateTime,
                    open: dto.openingPrice,
                    high: dto.highPrice,
                    low: dto.lowPrice,
                    close: dto.tradePrice,
                    trade: dto.candleAccTradePrice,
                    index: idx
                )
            }
    }
}
