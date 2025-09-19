//
//  WidgetUpbitAPIService.swift
//  iCOWidgetExtension
//
//  Created by 백현진 on 9/19/25.
//

import Foundation

struct MinuteCandleDTO: Codable {
    let tradePrice: Double
    
    enum CodingKeys: String, CodingKey {
        case tradePrice = "trade_price"
    }
}

struct TickerDTO: Codable {
    let market: String
    let tradePrice: Double
    let signedChangeRate: Double
    
    enum CodingKeys: String, CodingKey {
        case market
        case tradePrice = "trade_price"
        case signedChangeRate = "signed_change_rate"
    }
}

/// 위젯 전용 간단한 API 클라이언트
final class UpBitWidgetAPI {
    /// 특정 코인의 현재 시세
    func fetchQuotes(id: String) async throws -> TickerDTO? {
        let url = URL(string: "https://api.upbit.com/v1/ticker?markets=\(id)")!
        let (data, _) = try await URLSession.shared.data(from: url)
        let tickers = try JSONDecoder().decode([TickerDTO].self, from: data)
        return tickers.first
    }

    /// 특정 코인의 최근 분봉 캔들
    func fetchCandles(id: String, count: Int = 10) async throws -> [MinuteCandleDTO] {
        let url = URL(string: "https://api.upbit.com/v1/candles/minutes/1?market=\(id)&count=\(count)")!
        let (data, _) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode([MinuteCandleDTO].self, from: data)
    }
}
