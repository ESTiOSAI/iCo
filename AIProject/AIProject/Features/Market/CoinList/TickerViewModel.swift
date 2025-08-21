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
    
    private(set) var snapshot: TickerValue
    
    var signedRate: Double { snapshot.signedRate }
    
    init(coinID: CoinID) {
        self.coinID = coinID
        self.snapshot = TickerValue(id: coinID, price: 0, volume: 0, rate: 0, change: .even)
    }
    
    @MainActor
    func apply(_ value: TickerValue) {
        if self.snapshot != value {
            self.snapshot = value
        }
    }
}
