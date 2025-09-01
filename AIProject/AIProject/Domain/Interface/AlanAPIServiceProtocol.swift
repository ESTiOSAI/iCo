//
//  AlanAPIServiceProtocol.swift
//  AIProject
//
//  Created by kangho lee on 8/19/25.
//

import Foundation

/// 사용자의 성향과 북마크 코인을 기반으로 추천 코인을 가져오는 서비스 프로토콜입니다.
protocol AlanRecommendServiceProtocol: Sendable {
    func fetchRecommendCoins(preference: String, bookmarkCoins: String, ignoreCache: Bool) async throws -> [RecommendCoinDTO]
}

/// 코인 리포트(개요, 주간 동향, 오늘 뉴스)를 가져오는 서비스 프로토콜입니다.
protocol AlanReportServiceProtocol: Sendable {
    func fetchOverview(for coin: Coin) async throws -> CoinOverviewDTO
    func fetchWeeklyTrends(for coin: Coin) async throws -> CoinWeeklyDTO
    func fetchTodayNews(for coin: Coin) async throws -> CoinTodayNewsDTO
}

/// Alan API와 통신하기 위한 통합 서비스 프로토콜입니다.
///
/// 추천 서비스(`AlanRecommendServiceProtocol`)와 리포트 서비스(`AlanReportServiceProtocol`)를 모두 포함합니다.
protocol AlanAPIServiceProtocol: AlanRecommendServiceProtocol, AlanReportServiceProtocol { }
