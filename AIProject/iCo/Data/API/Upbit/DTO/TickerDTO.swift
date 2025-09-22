//
//  CoinQuoteDTO.swift
//  AIProject
//
//  Created by 강대훈 on 7/30/25.
//

import Foundation

/// 특정 코인의 실시간 시세, 다양한 시세 관련 정보를 포함하는 데이터 DTO
struct TickerDTO: Decodable {

    /// 코인 마켓 코드
    let coinID: String

    /// 최근 체결 일자 및 시각
    @Default<Int>
    var tradeTimestamp: Int

    /// 당일 시가
    @Default<Double>
    var openingPrice: Double
    /// 당일 고가
    @Default<Double>
    var highPrice: Double
    /// 당일 저가
    @Default<Double>
    var lowPrice: Double
    /// 현재가
    ///
    @Default<Double>
    var tradePrice: Double
    /// 전일 종가
    @Default<Double>
    var prevClosingPrice: Double

    /// 전일 대비 가격 변화 (RISE, FALL, EVEN)
    var change: String
    /// 전일 대비 가격 변화
    @Default<Double>
    var changePrice: Double
    /// 전일 대비 가격 변화 비율
    @Default<Double>
    var changeRate: Double

    /// 최근 거래 체결량
    @Default<Double>
    var tradeVolume: Double
    /// 당일 누적 거래대금
    @Default<Double>
    var accTradePrice: Double
    /// 당일 누적 거래량
    @Default<Double>
    var accTradeVolume: Double

    /// 52주 최고가
    @Default<Double>
    var highest52WeekPrice: Double
    /// 52주 최고가 날짜
    @Default<String>
    var highest52WeekDate: String
    /// 52주 최저가
    @Default<Double>
    var lowest52WeekPrice: Double
    /// 52주 최저가 날짜
    @Default<String>
    var lowest52WeekDate: String

    @Default<Int>
    var timestamp: Int

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
        case accTradeVolume = "acc_trade_price_24h"

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

    func toDomain() -> TickerValue {
        TickerValue(
            id: coinID,
            price: tradePrice,
            volume: accTradeVolume,
            rate: changeRate,
            change: .init(
                rawValue: change
            )
        )
    }
}
