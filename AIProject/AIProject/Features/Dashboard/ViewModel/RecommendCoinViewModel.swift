//
//  DashboardViewModel.swift
//  AIProject
//
//  Created by 강대훈 on 8/1/25.
//

import SwiftUI

final class RecommendCoinViewModel: ObservableObject {
    /// 추천 코인 배열
    @Published var recommendCoins: [RecommendCoin] = []

    private var alanService: AlanAPIService
    private var upbitService: UpBitAPIService

    init() {
        alanService = AlanAPIService()
        upbitService = UpBitAPIService()
    }
    
    /// 비동기로 추천 코인 목록을 가져와 `recommendCoins`에 할당합니다.
    func getRecommendCoin() async {
        do {
            let prompt = Prompt.recommendCoin(preference: "초보자", bookmark: "비트코인, 이더리움")
            let jsonString = try await alanService.fetchAnswer(content: prompt.content, action: .coinRecomendation).content.extractedJSON

            if let jsonData = jsonString.data(using: .utf8) {
                let recommendCoinDTOs = try JSONDecoder().decode([RecommendCoinDTO].self, from: jsonData)
                let results = try await fetchRecommendCoins(from: recommendCoinDTOs)

                Task { @MainActor in
                    recommendCoins = results
                }
            }
        } catch {
            print(error.localizedDescription)
        }
    }

    private func fetchRecommendCoins(from dtos: [RecommendCoinDTO]) async throws -> [RecommendCoin] {
        try await withThrowingTaskGroup(of: RecommendCoin?.self) { group in
            for dto in dtos {
                group.addTask {
                    guard let data = try await self.upbitService.fetchQuotes(id: dto.symbol).first else {
                        return nil
                    }

                    return RecommendCoin(
                        coinImage: nil,
                        comment: dto.comment,
                        coinID: data.coinID,
                        name: dto.name,
                        tradePrice: data.tradePrice,
                        changeRate: data.changeRate
                    )
                }
            }

            var results: [RecommendCoin] = []

            for try await coin in group {
                if let coin = coin {
                    results.append(coin)
                }
            }

            return results
        }
    }
}
