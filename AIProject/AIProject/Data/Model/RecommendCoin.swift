//
//  RecommendCoin.swift
//  AIProject
//
//  Created by 강대훈 on 8/1/25.
//

import SwiftUI

struct RecommendCoin: Identifiable {
    var id: String { coinID }

    let coinImage: UIImage?
    let comment: String
    let coinID: String
    let name: String
    let tradePrice: Double
    let changeRate: Double
}
