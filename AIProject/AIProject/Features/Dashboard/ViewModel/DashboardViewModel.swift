//
//  DashboardViewModel.swift
//  AIProject
//
//  Created by 강대훈 on 8/1/25.
//

import SwiftUI

final class DashboardViewModel: ObservableObject {
    /// 추천 코인 배열
    @Published var recommendCoin: [RecommendCoin] = []

    private var alanService: AlanAPIService
    private var upbitService: UpBitAPIService

    init() {
        alanService = AlanAPIService()
        upbitService = UpBitAPIService()
    }

    func getRecommendCoin() {
        recommendCoin = [
            RecommendCoin(comment: "좋다!", coinID: "KRW-BTCa"),
            RecommendCoin(comment: "좋다!", coinID: "KRW-BTCb"),
            RecommendCoin(comment: "좋다!", coinID: "KRW-BTCc"),
            RecommendCoin(comment: "좋다!", coinID: "KRW-BTCd"),
            RecommendCoin(comment: "좋다!", coinID: "KRW-BTCe"),
        ]
    }
}
