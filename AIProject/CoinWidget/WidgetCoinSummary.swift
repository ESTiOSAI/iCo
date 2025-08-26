//
//  WidgetCoinSummary.swift
//  CoinWidgetExtension
//
//  Created by 백현진 on 8/26/25.
//

public struct WidgetCoinSummary: Codable, Hashable {
    public let id: String          // ex) "KRW-BTC"
    public let koreanName: String  // ex) "비트코인"
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
