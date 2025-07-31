//
//  CoinDTO.swift
//  AIProject
//
//  Created by 강대훈 on 7/31/25.
//

import Foundation

/// WebSocket으로부터 오는 실시간 시세 데이터 DTO
struct RealTimeTickerDTO: Decodable {
    /// 종목 코드
    let code: String
    /// 현재 체결 가격
    let tradePrice: Double
    /// 전일 대비 변화 (RISE, FALL, EVEN)
    let change: String
    /// 전일 대비 가격 변화
    let changePrice: Double
    /// 전일 대비 등락률
    let changeRate: Double

    enum CodingKeys: String, CodingKey {
        case code
        case tradePrice = "trade_price"
        case change
        case changePrice = "change_price"
        case changeRate = "change_rate"
    }
}

