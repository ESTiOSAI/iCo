//
//  Response.swift
//  AIProject
//
//  Created by kangho lee on 7/29/25.
//

import Foundation

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
