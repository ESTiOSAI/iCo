//
//  Coin.swift
//  AIProject
//
//  Created by 장지현 on 7/31/25.
//

import Foundation

struct Coin: Identifiable, Hashable, Codable {
    let id: String
    let koreanName: String
}

extension Coin {
    var toData: Data? {
        try? JSONEncoder().encode(self)
    }
}
