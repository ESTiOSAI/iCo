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
    
    init(api: UpBitAPIService = .init()) {
        self.api = api
    }
    
    func fetchPrices(market: String, interval: CoinInterval) async throws -> [CoinPrice] {
        let count = interval.candleCount
        
        let DTOs = try await api.fetchCandles(id: market, count: count)
        
        let prices = DTOs.map { dto in
            CoinPrice(date: dto.tradeDateTime, close: dto.tradePrice)
        }
        .sorted(by: { $0.date < $1.date })
        
        return prices
    }
}
