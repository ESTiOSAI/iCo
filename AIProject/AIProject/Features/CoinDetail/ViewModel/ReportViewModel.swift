//
//  ReportViewModel.swift
//  AIProject
//
//  Created by 장지현 on 8/1/25.
//

import Foundation

final class ReportViewModel: ObservableObject {
    let coin: Coin
    let koreanName: String
    
    init(coin: Coin) {
        self.coin = coin
        self.koreanName = coin.koreanName
    }
}
