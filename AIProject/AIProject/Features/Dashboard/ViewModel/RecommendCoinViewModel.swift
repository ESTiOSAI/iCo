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

    var currentIndex: Int = 0

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
        loadRecommendCoin()
    }

    /// 비동기로 추천 코인 목록을 가져옵니다.
    func loadRecommendCoin() {
                let jsonString =
              """
              [
              {
              "name": "메이플 파이낸스",
              "symbol": "KRW-SYRUP",
              "comment": "업비트 원화 마켓에 최근 새로 상장되어 거래량과 가격이 급등했으며, 상장 공지 직후에는 95% 가까이 상승하는 등 변동성이 높아 관심을 끌고 있어요."
              },
              {
              "name": "비트코인",
              "symbol": "KRW-BTC",
              "comment": "최근 글로벌 기관 매수세가 유입되며 가격이 안정적으로 상승세를 이어가고 있어요."
              },
              {
              "name": "이더리움",
              "symbol": "KRW-ETH",
              "comment": "이더리움 네트워크 업그레이드 이후 거래 수수료 안정과 함께 디파이 거래량이 증가하고 있어요."
              },
              {
              "name": "솔라나",
              "symbol": "KRW-SOL",
              "comment": "최근 Solana 생태계에서 활발한 NFT 프로젝트와 디파이 서비스가 늘어나며 거래량이 크게 증가했어요."
              },
              {
              "name": "리플",
              "symbol": "KRW-XRP",
              "comment": "미국 법원 판결에서 리플에 유리한 결과가 이어지며 투자심리가 회복되고 있어요."
              },
              {
              "name": "아발란체",
              "symbol": "KRW-AVAX",
              "comment": "여러 디파이 플랫폼이 아발란체 네트워크로 이전하며 거래 활동이 활발해지고 있어요."
              }
              ]
              """

        task = Task {
            do {
                await MainActor.run {
                    recommendCoins = []
                    status = .loading
                }

                let bookmarkCoins = try BookmarkManager.shared.fetchRecent(limit: 5).map { $0.coinKoreanName }.joined(separator: ", ")
                let recommendCoinDTOs = try await alanService.fetchRecommendCoins(preference: "초보자", bookmarkCoins: bookmarkCoins)
                //let recommendCoinDTOs = try JSONDecoder().decode([RecommendCoinDTO].self, from: jsonString.data(using: .utf8)!)
                let results = try await fetchRecommendCoins(from: recommendCoinDTOs)

                await MainActor.run {
                    recommendCoins = results
                    status = .success
                }

            } catch is CancellationError {
                await MainActor.run { status = .cancel(.taskCancelled) }
            } catch let error as NetworkError {
                await MainActor.run { status = .failure(error) }
            } catch {
                print("알 수 없는 에러 발생.")
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
