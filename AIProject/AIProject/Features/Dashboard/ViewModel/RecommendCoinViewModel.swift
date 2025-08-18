//
//  DashboardViewModel.swift
//  AIProject
//
//  Created by 강대훈 on 8/1/25.
//

import SwiftUI

protocol AlanAPIServiceProtocol {
    func fetchRecommendCoins(preference: String, bookmarkCoins: String) async throws -> [RecommendCoinDTO]
}

protocol UpBitApiServiceProtocol {
    func fetchQuotes(id: String) async throws -> [TickerDTO]
}

final class RecommendCoinViewModel: ObservableObject {
    /// 현재 추천 코인 뷰의 UI 상태를 나타냅니다.
    ///
    /// `state`는 로딩, 성공, 실패 등의 화면 표현을 의미합니다.
    @Published var status: ResponseStatus = .loading
    @Published var recommendCoins: [RecommendCoin] = []

    private var alanService: AlanAPIServiceProtocol
    private var upbitService: UpBitApiServiceProtocol

    var task: Task<Void, Never>?

    var timer = Timer.publish(every: 3, on: .main, in: .common).autoconnect()
    var currentIndex: Int = 0

    var isSuccess: Bool {
        switch status {
        case .success:
            return true
        default:
            return false
        }
    }

    init(
        alanService: AlanAPIServiceProtocol = AlanAPIService(),
        upbitService: UpBitApiServiceProtocol = UpBitAPIService()
    ) {
        self.alanService = alanService
        self.upbitService = upbitService
        loadRecommendCoin()
    }

    /// 비동기로 추천 코인 목록을 가져옵니다.
    func loadRecommendCoin() {
        task = Task {
            do {
                await MainActor.run {
                    recommendCoins = []
                    status = .loading
                }

                let bookmarkCoins = try BookmarkManager.shared.fetchAll().map { $0.coinKoreanName }.joined(separator: ", ")
                let recommendCoinDTOs = try await alanService.fetchRecommendCoins(preference: "초보자", bookmarkCoins: bookmarkCoins)
                let results = try await fetchRecommendCoins(from: recommendCoinDTOs)

                await MainActor.run {
                    recommendCoins = results
                    status = .success
                }

            } catch is CancellationError {
                await MainActor.run {
                    status = .cancel(.taskCancelled)
                    recommendCoins = []
                }
            } catch let error as NetworkError {
                await MainActor.run {
                    status = .failure(error)
                    recommendCoins = []
                }
            } catch {
                print("알 수 없는 에러 발생.")
            }
        }
    }

    /// 코인 추천 작업을 취소합니다.
    func cancelTask() async {
        task?.cancel()
        await task?.value
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
                        coinID: data.coinID.replacingOccurrences(of: "KRW-", with: ""),
                        name: dto.name,
                        tradePrice: data.tradePrice,
                        changeRate: data.changeRate,
                        changeType: RecommendCoin.TickerChangeType(rawValue: data.change)
                    )
                }
            }

            var results: [RecommendCoin] = []

            for try await coin in group {
                if let coin = coin {
                    results.append(coin)

                    if results.count == 5 {
                        group.cancelAll()
                        break
                    }
                }
            }

            return results
        }
    }
}
