//
//  CoinInterval.swift
//  AIProject
//
//  Created by 강민지 on 8/1/25.
//

import Foundation

enum CoinInterval: String, CaseIterable, Identifiable {
    case d1 = "1D"
    case w1 = "1W"
    case m3 = "3M"
    case m6 = "6M"
    case y1 = "1Y"
    var id: String { rawValue }
}
