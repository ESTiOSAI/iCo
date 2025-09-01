//
//  Coin.swift
//  AIProject
//
//  Created by 장지현 on 7/31/25.
//

import Foundation

typealias CoinID = String

/// 개별 코인 정보를 나타내는 모델입니다.
///
/// - id: 코인의 고유 식별자 (예: "KRW-BTC")
/// - koreanName: 한글 이름  (예: "비트코인")
/// - imageURL: 코인 이미지의 원격 URL (선택 사항)
struct Coin: Identifiable, Hashable, Codable {
    let id: String
    let koreanName: String
    var imageURL: URL?
}

extension Coin {
    /// 현재 `Coin` 객체를 JSON 데이터로 인코딩합니다.
    ///
    /// - Returns: 성공 시 JSON `Data`, 실패 시 `nil`
    var toData: Data? {
        try? JSONEncoder().encode(self)
    }
}

/// 코인 심볼 문자열을 변환하기 위한 프로토콜입니다.
protocol CoinSymbolConvertible {
    /// 코인의 심볼 문자열 (예: "KRW-BTC" → "BTC")
    var coinSymbol: String { get }
}

extension Coin: CoinSymbolConvertible {
    /// 코인의 ID에서 마켓 구분자를 제거하고 심볼만 반환합니다.
    ///
    /// - Returns: 예: `"KRW-BTC"` → `"BTC"`
    var coinSymbol: String {
        id.components(separatedBy: "-").last ?? id
    }
}
