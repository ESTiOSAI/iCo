//
//  WidgetCoinSummary.swift
//  iCo
//
//  Created by 백현진 on 9/18/25.
//

import Foundation

public struct WidgetCoinSummary: Codable, Hashable {
    public let id: String
    public let koreanName: String
    public let price: Double
    public let change: Double
    public let history: [Double]

    public init(id: String, koreanName: String, price: Double, change: Double, history: [Double]) {
        self.id = id
        self.koreanName = koreanName
        self.price = price
        self.change = change
        self.history = history
    }

    public var symbol: String {
        id.components(separatedBy: "-").last ?? id
    }
}
