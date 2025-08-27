//
//  SearchViewModel.swift
//  AIProject
//
//  Created by 강대훈 on 8/5/25.
//

import SwiftUI
import AsyncAlgorithms

final class SearchViewModel: ObservableObject {
    @Published var recentSearchCoins: [Coin] = []
    @Published var relatedCoins: [Coin] = []

    private var upbitService: UpBitAPIService

    private var continuation: AsyncStream<String>.Continuation?
    private var task: Task<Void, Never>?
    
    private var coins = [Coin]()

    init(upbitService: UpBitAPIService = UpBitAPIService()) {
        self.upbitService = upbitService
        setupCoinData()
        observeStream()
    }

    /// 검색 키워드를 스트림에 전달합니다.
    /// - Parameter keyword: 사용자가 입력한 검색어 문자열입니다.
    func sendKeyword(with keyword: String) async {
        continuation?.yield(keyword)
    }

    /// 업비트에 존재하는 모든 코인 목록을 받아옵니다.
    private func setupCoinData() {
        Task {
            do {
                let coinDTOs = try await upbitService.fetchMarkets()
                coins = coinDTOs.map { Coin(id: $0.coinID.replacingOccurrences(of: "KRW-", with: ""), koreanName: $0.koreanName) }
                print(coins)
            } catch {
                print(error.localizedDescription)
            }
        }
    }

    /// 사용자 검색어 스트림을 관찰하고 검색을 트리거합니다.
    ///
    /// - 해당 메소드는 0.3초의 디바운스가 적용되어 있습니다.
    private func observeStream() {
        let stream = AsyncStream<String> { continuation in
            self.continuation = continuation
        }

        task = Task {
            for await keyword in stream.removeDuplicates().debounce(for: .seconds(0.3)) {
                await performSearch(with: keyword)
            }
        }
    }

    /// 주어진 키워드를 기반으로 관련 코인 목록을 필터링하여 갱신합니다.
    ///
    /// - Parameter keyword: 사용자가 입력한 검색어입니다.
    private func performSearch(with keyword: String) async {
        guard !keyword.isEmpty else {
            await MainActor.run { relatedCoins = [] }
            return
        }

        let filteredCoins = coins.filter { $0.koreanName.contains(keyword) || $0.id.lowercased().contains(keyword.lowercased()) }
        await MainActor.run { relatedCoins = filteredCoins }
    }

    deinit {
        task?.cancel()
        task = nil
    }
}
