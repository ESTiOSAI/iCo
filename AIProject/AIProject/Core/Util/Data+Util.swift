//
//  Data+Util.swift
//  AIProject
//
//  Created by 강대훈 on 8/6/25.
//

import Foundation

extension Data {
    /// 코인 데이터로 디코드해서 반환합니다.
    var toCoin: Coin? {
        try? JSONDecoder().decode(Coin.self, from: self)
    }
}
