//
//  DashboardViewModel.swift
//  AIProject
//
//  Created by 강대훈 on 8/1/25.
//

import SwiftUI

final class RecommendCoinViewModel: ObservableObject {
    /// 현재 추천 코인 뷰의 UI 상태를 나타냅니다.
    ///
    /// `state`는 로딩, 성공, 실패 등의 화면 표현을 의미합니다.
    @Published var status: ResponseStatus = .loading
    @Published var recommendCoins: [RecommendCoin] = []

    private var alanService: AlanAPIService
    private var upbitService: UpBitAPIService

    private var task: Task<Void, Never>?

    var isSuccess: Bool {
        switch status {
        case .success:
            return true
        default:
            return false
        }
    }

    init() {
        alanService = AlanAPIService()
        upbitService = UpBitAPIService()
    }

    /// 비동기로 추천 코인 목록을 가져옵니다.

        task = Task {
            do {
                await MainActor.run {
                    recommendCoins = []
                    status = .loading
                }

                let bookmarkCoins = try BookmarkManager.shared.fetchRecent(limit: 5).map { $0.coinKoreanName }.joined(separator: ", ")
                let recommendCoinDTOs = try await alanService.fetchRecommendCoins(preference: "초보자", bookmarkCoins: bookmarkCoins)
                let results = try await fetchRecommendCoins(from: recommendCoinDTOs)

                await MainActor.run {
                    recommendCoins = results
                    status = .success
                }

            } catch let error as CancellationError {
                await MainActor.run { status = .cancel(error) }
            } catch {
                print(error)
                await MainActor.run { status = .failure(error) }
            }
        }
    }

    /// 코인 추천 작업을 취소합니다.
    func cancelTask() {
        task?.cancel()
        task = nil
    }

    private func fetchRecommendCoins(from dtos: [RecommendCoinDTO]) async throws -> [RecommendCoin] {
        try await withThrowingTaskGroup(of: RecommendCoin?.self) { group in
            for dto in dtos {
                group.addTask {
                    guard let data = try await self.upbitService.fetchQuotes(id: dto.symbol).first else {
                        print("CoinRecommendViewModel - 존재하지 않는 CoinID")
                        return nil
                    }

                    return RecommendCoin(
                        imageURL: nil,
                        comment: dto.comment,
                        coinID: data.coinID,
                        name: dto.name,
                        tradePrice: data.tradePrice,
                        changeRate: data.change == "FALL" ? -data.changeRate : data.changeRate
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
