//
//  Response.swift
//  AIProject
//
//  Created by kangho lee on 7/29/25.
//

import Foundation

/// 업비트에서 거래 가능한 종목 목록 DTO
struct MarketDTO: Codable {
    let market: String
    let koreanName: String
    let englishName: String

    enum CodingKeys: String, CodingKey {
        case market
        case koreanName = "korean_name"
        case englishName = "english_name"
    }
}
