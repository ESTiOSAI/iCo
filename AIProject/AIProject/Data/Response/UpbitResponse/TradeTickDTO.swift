//
//  TradeTick.swift
//  AIProject
//
//  Created by 강대훈 on 7/30/25.
//

import Foundation

/// 가장 최근에 체결된 내역 데이터 DTO
struct TradeTickDTO: Codable {
    let market: String
    let tradeDateUTC: String
    let tradeTimeUTC: String
    let timestamp: Int
    let tradePrice: Double
    let tradeVolume: Double
    let prevClosingPrice: Double
    let changePrice: Double

    enum CodingKeys: String, CodingKey {
        case market
        case tradeDateUTC = "trade_date_utc"
        case tradeTimeUTC = "trade_time_utc"
        case timestamp
        case tradePrice = "trade_price"
        case tradeVolume = "trade_volume"
        case prevClosingPrice = "prev_closing_price"
        case changePrice = "change_price"
    }
}
