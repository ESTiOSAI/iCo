//
//  FakePriceService.swift
//  AIProject
//
//  Created by 강민지 on 8/20/25.
//

import Foundation

/// PR용 테스트 (머지 전 삭제)
#if DEBUG
struct FakePriceService: CoinPriceProvider {
    enum Mode {
        case success(delaySec: Double, points: Int = 120) // 지연 후 성공
        case empty(delaySec: Double)                      // 지연 후 빈 배열
        case failure(delaySec: Double)                    // 지연 후 에러
    }
    let mode: Mode

    func fetchPrices(market: String, interval: CoinInterval, to: Date?) async throws -> [CoinPrice] {
        // 지연 주기
        let ns: UInt64 = {
            switch mode {
            case .success(let d, _), .empty(let d), .failure(let d): return UInt64(d * 1_000_000_000)
            }
        }()
        try await Task.sleep(nanoseconds: ns)
        try Task.checkCancellation()
        
        // 모드 분기
        switch mode {
        case .success(_, let points):
            let now = Date()
            // 간단한 더미 OHLC 생성
            let data: [CoinPrice] = (0..<points).map { i in
                let t = now.addingTimeInterval(Double(-(points - i)) * 60)
                let base = 10_000.0
                return .init(
                    date: t, open: base, high: base * 1.01, low: base * 0.99,
                    close: base * (0.995 + Double(i)/Double(points)/100.0),
                    trade: 1_234_567, index: i)
            }
            return data
        case .empty:
            return []
        case .failure:
            throw NetworkError.invalidResponse
        }
    }
}
#endif
