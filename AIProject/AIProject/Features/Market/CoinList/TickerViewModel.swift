//
//  TickerViewModel.swift
//  AIProject
//
//  Created by kangho lee on 8/18/25.
//

import Foundation

/// 코인 셀의 시세 정보를 저장하고 있는 객체
@Observable
final class TickerStore {
    let coinID: String
    
    // 시세 정보 데이터
    private(set) var snapshot: TickerValue
    
    // 등락폭 - 정렬 시 필요
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
