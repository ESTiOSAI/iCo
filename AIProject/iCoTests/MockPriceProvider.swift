//
//  MockPriceProvider.swift
//  AIProjectTests
//
//  Created by 강민지 on 8/18/25.
//

import Foundation
@testable import AIProject

/// 네트워크 호출 없이 테스트가 원하는 결과/에러를 주입하는 더블(Mock)
final class MockPriceProvider: CoinPriceProvider {
    var result: [CoinPrice] = []
    var error: Error?

    func fetchPrices(market: String, interval: CoinInterval, to: Date?) async throws -> [CoinPrice] {
        if let error { throw error }
        return result
    }

    func fetchPrices(market: String, interval: CoinInterval) async throws -> [CoinPrice] {
        if let error { throw error }
        return result
    }
}

func makePrice(_ date: Date, _ open: Double, _ close: Double) -> CoinPrice {
    CoinPrice(
        date: date,
        open: open,
        high: max(open, close) + 1,
        low:  min(open, close) - 1,
        close: close,
        trade: 1_000_000,
        index: 999
    )
}
