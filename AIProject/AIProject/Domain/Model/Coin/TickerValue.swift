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

extension TickerValue {
    private var code: String {
        switch change {
        case .rise: return "▲"
        case .even: return ""
        case .fall: return "▼"
        }
    }
    
    var formatedRate: String {
        code + rate.formatted(.percent.precision(.fractionLength(2)))
    }
    
    var formatedPrice: String {
        price.formatted(.number) + "원"
    }
    
    var formatedVolume: String {
        volume.formatMillion
    }
}
