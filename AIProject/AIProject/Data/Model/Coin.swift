//
//  Coin.swift
//  AIProject
//
//  Created by 장지현 on 7/31/25.
//

import Foundation

/// 개별 코인 정보를 나타내는 모델입니다.
///
/// - id: 코인의 고유 식별자 (예: "KRW-BTC")
/// - koreanName: 한글 이름  (예: "비트코인")
struct Coin: Identifiable, Hashable, Codable {
    let id: String
    let koreanName: String
    var imageURL: URL?
}

extension Coin {
    var toData: Data? {
        try? JSONEncoder().encode(self)
    }
}

protocol CoinSymbolConvertible {
    var coinSymbol: String { get }
}

extension Coin: CoinSymbolConvertible {
    var coinSymbol: String {
        id.components(separatedBy: "-").last ?? id
    }
}
