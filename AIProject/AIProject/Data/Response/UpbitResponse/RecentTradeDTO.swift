//
//  TradeTick.swift
//  AIProject
//
//  Created by 강대훈 on 7/30/25.
//

import Foundation

/// 가장 최근에 체결된 내역 데이터 DTO
struct RecentTradeDTO: Codable {
    /// 마켓 코드
    let market: String
    /// 체결 일자
    let tradeDate: String
    /// 체결 시간
    let tradeTime: String
    /// 체결 발생 시각
    let timestamp: Int
    /// 체결 가격
    let tradePrice: Double
    /// 체결 수량
    let tradeVolume: Double
    /// 전일 종가
    let prevClosingPrice: Double
    /// 전일 대비 가격 변화량
    let changePrice: Double

    enum CodingKeys: String, CodingKey {
        case market
        case tradeDate = "trade_date_utc"
        case tradeTime = "trade_time_utc"
        case timestamp
        case tradePrice = "trade_price"
        case tradeVolume = "trade_volume"
        case prevClosingPrice = "prev_closing_price"
        case changePrice = "change_price"
    }
}

extension RecentTradeDTO {
    /// 체결 일자 및 시간을 Date 형식으로 반환합니다.
    var tradeDateTime: Date {
        Date(timeIntervalSince1970: TimeInterval(timestamp) / 1000)
    }
}
