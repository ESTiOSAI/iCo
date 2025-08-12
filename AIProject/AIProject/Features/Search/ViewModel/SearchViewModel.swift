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
    private var imageService: CoinGeckoAPIService

    private var coins: [Coin] = []

    private var continuation: AsyncStream<String>.Continuation?
    private var task: Task<Void, Never>?

    init(upbitService: UpBitAPIService = UpBitAPIService(), imageService: CoinGeckoAPIService = CoinGeckoAPIService()) {
        self.upbitService = upbitService
        self.imageService = imageService
        setupCoinData()
        observeStream()
    }
    
    /// 최근 검색 기록을 받아옵니다.
    func loadRecentSearchKeyword() {
        guard let recentSearchCoins = UserDefaults.standard.array(forKey: "recentSearchCoins") as? [Data] else {
            recentSearchCoins = []
            return
        }

        self.recentSearchCoins = recentSearchCoins.compactMap { $0.toCoin }
    }
    
    /// 최근 검색 기록에 업데이트합니다.
    /// - Parameter coin: 추가할 코인 데이터입니다.
    func updateRecentSearchKeyword(_ coin: Coin) {
        if recentSearchCoins.contains(where: { $0.id == coin.id }) {
            removeRecentSearchKeyword(coin)
        }

        recentSearchCoins.insert(coin, at: 0)
        UserDefaults.standard.set(recentSearchCoins.compactMap { $0.toData }, forKey: "recentSearchCoins")
    }

    
    /// 최근 검색 기록을 삭제합니다.
    /// - Parameter coin: 삭제할 코인 데이터입니다.
    func removeRecentSearchKeyword(_ coin: Coin) {
        if let index = recentSearchCoins.firstIndex(where: { $0.id == coin.id }) {
            recentSearchCoins.remove(at: index)
            UserDefaults.standard.set(recentSearchCoins.compactMap { $0.toData }, forKey: "recentSearchCoins")
        }
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
                coins = coinDTOs.map { Coin(id: $0.coinID, koreanName: $0.koreanName.replacingOccurrences(of: "KRW-", with: "")) }
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

        do {
            // 이전 작업을 취소하는 어떤 기능이 필요함..
            let coinWithURLs = try await setImageURL(filteredCoins)
            await MainActor.run {relatedCoins = coinWithURLs }
        } catch {
            // ImageURL을 받아오는데 실패했기 때문에 대체 이미지를 가져와야 함.
            await MainActor.run { relatedCoins = filteredCoins }
        }
    }

    deinit {
        task?.cancel()
        task = nil
    }
}

extension SearchViewModel {
    private func setImageURL(_ coins: [Coin]) async throws -> [Coin] {
        var tempCoins = coins
        let symbols = coins.map { $0.id.replacingOccurrences(of: "KRW-", with: "") }
        let urls = try await imageService.fetchCoinImages(symbols: symbols).map { $0.imageURL }

        for i in 0..<urls.count {
            tempCoins[i].imageURL = urls[i]
        }

        return tempCoins
    }
}
