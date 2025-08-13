//
//  RecommendCoin.swift
//  AIProject
//
//  Created by 강대훈 on 8/1/25.
//

import SwiftUI

struct RecommendCoin: Identifiable {
    var id: String { coinID }

    var imageURL: URL?
    let comment: String
    let coinID: String
    let name: String
    let tradePrice: Double
    let changeRate: Double
}

extension RecommendCoin {
    static var dummyDatas: [RecommendCoin] =
    	[
        RecommendCoin(comment: "펏지펭귄은 활발한 커뮤니티와 밈 기반의 인기 덕분에 최근 주목 받고 있어요.", coinID: "BTX", name: "펏지펭귄", tradePrice: 1.33, changeRate: -3.0),
        RecommendCoin(comment: "펏지펭귄은 활발한 커뮤니티와 밈 기반의 인기 덕분에 최근 주목 받고 있어요.", coinID: "BTC", name: "펏지펭귄", tradePrice: 1.33, changeRate: -3.0),
        RecommendCoin(comment: "펏지펭귄은 활발한 커뮤니티와 밈 기반의 인기 덕분에 최근 주목 받고 있어요.", coinID: "ETC", name: "펏지펭귄", tradePrice: 1.33, changeRate: -3.0),
        RecommendCoin(comment: "펏지펭귄은 활발한 커뮤니티와 밈 기반의 인기 덕분에 최근 주목 받고 있어요.", coinID: "LTC", name: "펏지펭귄", tradePrice: 1.33, changeRate: -3.0),
        RecommendCoin(comment: "펏지펭귄은 활발한 커뮤니티와 밈 기반의 인기 덕분에 최근 주목 받고 있어요.", coinID: "DTC", name: "펏지펭귄", tradePrice: 1.33, changeRate: -3.0),
        ]
}
