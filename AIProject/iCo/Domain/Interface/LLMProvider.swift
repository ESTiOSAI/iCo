//
//  LLMProvider.swift
//  iCo
//
//  Created by 강대훈 on 9/17/25.
//

import Foundation

protocol LLMProvider {
    func postAnswer(content: String, action: LLMAction) async throws -> LLMResponseDTO
    func fetchRecommendCoins(preference: String, bookmarkCoins: String, ignoreCache: Bool) async throws -> [RecommendCoinDTO]
    func fetchOverview(for coin: Coin) async throws -> CoinOverviewDTO
    func fetchWeeklyTrends(for coin: Coin) async throws -> CoinWeeklyDTO
    func fetchTodayNews(for coin: Coin) async throws -> CoinTodayNewsDTO
    func fetchTodayInsight(ignoreCache: Bool) async throws -> Insight
    func fetchCommunityInsight(from post: String, now: Date, ignoreCache: Bool) async throws -> Insight
    func fetchBookmarkBriefing(for coins: [BookmarkEntity], character: RiskTolerance) async throws -> PortfolioBriefingDTO
}
