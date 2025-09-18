//
//  Response.swift
//  AIProject
//
//  Created by kangho lee on 7/29/25.
//

import Foundation

/// 업비트에서 거래 가능한 종목 목록 DTO
struct CoinDTO: Codable {
    /// 마켓 식별자
    let coinID: String
    /// 코인의 한글 이름 ex) 비트코인
    let koreanName: String
    /// 코인의 영문 이름 ex) Bitcoin
    let englishName: String

    enum CodingKeys: String, CodingKey {
        case coinID = "market"
        case koreanName = "korean_name"
        case englishName = "english_name"
    }
}

extension CoinDTO: CoinSymbolConvertible {
    var coinSymbol: String {
        coinID.components(separatedBy: "-").last ?? ""
    }
}
