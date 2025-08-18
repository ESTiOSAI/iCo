//
//  CoinQuoteDTO.swift
//  AIProject
//
//  Created by 강대훈 on 7/30/25.
//

import Foundation

/// 특정 코인의 실시간 시세, 다양한 시세 관련 정보를 포함하는 데이터 DTO
struct TickerDTO: Codable {
    /// 코인 마켓 코드
    let coinID: String
    /// 최근 체결 일자 및 시각
    let tradeTimestamp: Int

    /// 당일 시가
    let openingPrice: Double
    /// 당일 고가
    let highPrice: Double
    /// 당일 저가
    let lowPrice: Double
    /// 현재가
    let tradePrice: Double
    /// 전일 종가
    let prevClosingPrice: Double

    /// 전일 대비 가격 변화 (RISE, FALL, EVEN)
    let change: String
    /// 전일 대비 가격 변화
    let changePrice: Double
    /// 전일 대비 가격 변화 비율
    let changeRate: Double

    /// 최근 거래 체결량
    let tradeVolume: Double
    /// 당일 누적 거래대금
    let accTradePrice: Double
    /// 당일 누적 거래량
    let accTradeVolume: Double

    /// 52주 최고가
    let highest52WeekPrice: Double
    /// 52주 최고가 날짜
    let highest52WeekDate: String
    /// 52주 최저가
    let lowest52WeekPrice: Double
    /// 52주 최저가 날짜
    let lowest52WeekDate: String

    let timestamp: Int

    enum CodingKeys: String, CodingKey {
        case coinID = "market"
        case tradeTimestamp = "trade_timestamp"

        case openingPrice = "opening_price"
        case highPrice = "high_price"
        case lowPrice = "low_price"
        case tradePrice = "trade_price"
        case prevClosingPrice = "prev_closing_price"

        case change
        case changePrice = "change_price"
        case changeRate = "change_rate"

        case tradeVolume = "trade_volume"
        case accTradePrice = "acc_trade_price"
        case accTradeVolume = "acc_trade_volume"

        case highest52WeekPrice = "highest_52_week_price"
        case highest52WeekDate = "highest_52_week_date"
        case lowest52WeekPrice = "lowest_52_week_price"
        case lowest52WeekDate = "lowest_52_week_date"

        case timestamp
    }
}

extension TickerDTO: Sendable {
    /// 체결 일자 및 시간을 Date 형식으로 반환합니다.
    var tradeDateTime: Date {
        Date(timeIntervalSince1970: TimeInterval(tradeTimestamp) / 1000)
    }
}
