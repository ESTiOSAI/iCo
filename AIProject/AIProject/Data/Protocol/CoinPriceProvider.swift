//
//  CoinPriceProvider.swift
//  AIProject
//
//  Created by 강민지 on 8/1/25.
//

import Foundation

/// 코인 가격 데이터를 제공하는 서비스의 공통 인터페이스
protocol CoinPriceProvider {
    /// 지정된 마켓과 기간 조건에 따라 가격 데이터를 비동기적으로 로드
    ///
    /// - Parameters:
    ///   - market: 마켓 식별자 (예: "KRW-BTC")
    ///   - interval: 가격 차트의 기간 옵션 (예: .d1 = 1일)
    /// - Returns: 시계열 가격 데이터 배열
    func fetchPrices(market: String, interval: CoinInterval) async throws -> [CoinPrice]
}
