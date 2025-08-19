//
//  CandleDTO.swift
//  AIProject
//
//  Created by 강대훈 on 7/31/25.
//

import Foundation

/// 분 단위의 캔들 데이터 DTO
struct MinuteCandleDTO: Codable {
    /// 종목 코드
    let coinID: String
    /// 시가
    let openingPrice: Double
    /// 캔들 기준 시각
    let candleDateTime: String
    /// 고가
    let highPrice: Double
    /// 저가
    let lowPrice: Double
    /// 종가
    let tradePrice: Double
    /// 해당 캔들에서 마지막 틱이 저장된 시각
    let timestamp: Int
    /// 누적 거래 금액
    let candleAccTradePrice: Double
    /// 누적 거래량
    let candleAccTradeVolume: Double

    enum CodingKeys: String, CodingKey {
        case coinID = "market"
        case candleDateTime = "candle_date_time_kst"
        case openingPrice = "opening_price"
        case highPrice = "high_price"
        case lowPrice = "low_price"
        case tradePrice = "trade_price"
        case timestamp
        case candleAccTradePrice = "candle_acc_trade_price"
        case candleAccTradeVolume = "candle_acc_trade_volume"
    }
}

extension MinuteCandleDTO {
    /// 해당 캔들에서 마지막 틱이 저장된 시각을 Date 형식으로 반환합니다.
    var tradeDateTime: Date {
        Date(timeIntervalSince1970: TimeInterval(timestamp) / 1000)
    }
}
