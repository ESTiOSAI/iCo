//
//  TickerViewModel.swift
//  AIProject
//
//  Created by kangho lee on 8/18/25.
//

import Foundation

@Observable
final class TickerStore {
    let coinID: String
    var price: Double = 0
    var rate: Double = 0
    var volume: Double = 0
    var change: TickerValue.ChangeType = .even
    
    init(coinID: CoinID) {
        self.coinID = coinID
    }
    
    @MainActor
    func apply(_ value: TickerValue) {
        if price != value.price { price = value.price }
        if rate != value.rate { rate = value.rate }
        if volume != value.volume { volume = value.volume }
        if change != value.change { change = value.change }
    }
}
