//
//  CoinModel.swift
//  AIProject
//
//  Created by kangho lee on 7/31/25.
//

import Foundation

struct CoinListModel: Identifiable {
    let coinID: String
    var id: String {
        coinID
    }
    
    let image: String
    let name: String
    let currentPrice: Double
    let changePrice: Double
    let tradeAmount: Double
    
    var coinName: String {
        coinID.components(separatedBy: "-").last ?? ""
    }
}

extension CoinListModel {
    static let preview: [CoinListModel] = [
        .init(
            coinID: "KRW-BTC",
            image: "bitcoin",
            name: "비트코인",
            currentPrice: 1333,
            changePrice: 3,
            tradeAmount: 162140000
        ),

        .init(
            coinID: "KRW-ETH",
            image: "ethereum",
            name: "이더리움",
            currentPrice: 3500,
            changePrice: 1,
            tradeAmount: 122300000
        ),

        .init(
            coinID: "KRW-XRP",
            image: "ripple",
            name: "리플",
            currentPrice: 1230,
            changePrice: -50,
            tradeAmount: 50000000
        ),

        .init(
            coinID: "KRW-LTC",
            image: "litecoin",
            name: "라이트코인",
            currentPrice: 55000,
            changePrice: 500,
            tradeAmount: 8000000
        ),

        .init(
            coinID: "KRW-BCH",
            image: "bitcoin-cash",
            name: "비트코인 캐시",
            currentPrice: 650000,
            changePrice: 10,
            tradeAmount: 3000000
        ),

        .init(
            coinID: "KRW-DOGE",
            image: "dogecoin",
            name: "도지코인",
            currentPrice: 400,
            changePrice: 20,
            tradeAmount: 700000000
        ),

        .init(
            coinID: "KRW-ADA",
            image: "cardano",
            name: "카르다노",
            currentPrice: 1500,
            changePrice: 100,
            tradeAmount: 10000000
        ),

        .init(
            coinID: "KRW-TRX",
            image: "tron",
            name: "트론",
            currentPrice: 120,
            changePrice: -10,
            tradeAmount: 300000000
        ),

        .init(
            coinID: "KRW-SOL",
            image: "solana",
            name: "솔라나",
            currentPrice: 85000,
            changePrice: -500,
            tradeAmount: 25000000
        ),

        .init(
            coinID: "KRW-MATIC",
            image: "matic",
            name: "매틱",
            currentPrice: 1300,
            changePrice: 50,
            tradeAmount: 40000000
        )
    ]
}
