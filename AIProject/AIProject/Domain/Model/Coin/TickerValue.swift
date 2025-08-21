//
//  TickerValue.swift
//  AIProject
//
//  Created by kangho lee on 8/21/25.
//

import Foundation

struct TickerValue: Sendable, Identifiable, CoinSymbolConvertible {
    typealias ChangeType = CoinListModel.TickerChangeType
    let id: String
    let price: Double
    let volume: Double
    let rate: Double
    let change: ChangeType
    
    var coinSymbol: String {
        id.components(separatedBy: "-").last ?? ""
    }
    
    var signedRate: Double { change == .fall ? -rate : rate }
}

extension TickerValue: Equatable {
    static func == (lhs: TickerValue, rhs: TickerValue) -> Bool {
        lhs.id == rhs.id && lhs.price == rhs.price && lhs.rate == rhs.rate
    }
}
