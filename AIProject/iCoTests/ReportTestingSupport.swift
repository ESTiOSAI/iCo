//
//  ReportTestingSupport.swift
//  AIProjectTests
//
//  Created by 장지현 on 8/20/25.
//

import Foundation
import XCTest
@testable import iCo

// MARK: - Test Fixtures (테스트 더미 데이터)

enum TestFixtures {
    enum Overview {
        static let sample = CoinOverviewDTO(
            symbol: "BTC",
            websiteURL: "https://bitcoin.org",
            launchDate: "2009-01-03",
            description: "Mock Overview"
        )
    }

    enum Weekly {
        static let sample = CoinWeeklyDTO(
            priceTrend: "상승",
            volumeChange: "+12%",
            reason: "기관 유입"
        )
    }

    enum TodayNews {
        static func withArticles(_ count: Int) -> CoinTodayNewsDTO {
            let articles: [CoinArticleDTO] = (0..<count).map { i in
                CoinArticleDTO(
                    title: "제목\(i)",
                    summary: "요약\(i)",
                    newsSourceURL: "https://example.com/\(i)"
                )
            }
            return CoinTodayNewsDTO(
                summaryOfTodaysMarketSentiment: "중립",
                articles: articles
            )
        }
    }

    enum Coin {
        static let btc = iCo.Coin(id: "BTC", koreanName: "비트코인")
    }
}

// MARK: - SpyAlanAPIService (Report 전용 Spy)

/// Spy 설정이 누락되었을 때 테스트에서 빠르게 드러내기 위한 로컬 에러
private enum SpyError: Error { case unconfigured }

final class SpyAlanAPIService: AlanReportServiceProtocol, @unchecked Sendable {
    struct Config {
        var overviewDelayNS: UInt64 = 50_000_000
        var weeklyDelayNS: UInt64 = 50_000_000
        var todayDelayNS: UInt64 = 50_000_000
        
        var overviewResult: Result<CoinOverviewDTO, Error> = .failure(SpyError.unconfigured)
        var weeklyResult: Result<CoinWeeklyDTO, Error> = .failure(SpyError.unconfigured)
        var todayResult: Result<CoinTodayNewsDTO, Error> = .failure(SpyError.unconfigured)
    }
    
    var config = Config()
    
    // 시작 타임스탬프 (동시 시작/순서 검증 참고용)
    private(set) var overviewStart: Date?
    private(set) var weeklyStart: Date?
    private(set) var todayStart: Date?
    
    // 호출 횟수 카운터(원하실 경우 사용)
    private(set) var overviewCallCount = 0
    private(set) var weeklyCallCount = 0
    private(set) var todayCallCount = 0
    
    func fetchOverview(for coin: Coin) async throws -> CoinOverviewDTO {
        overviewCallCount += 1
        overviewStart = overviewStart ?? Date()
        try await Task.sleep(nanoseconds: config.overviewDelayNS)
        return try config.overviewResult.get()
    }
    
    func fetchWeeklyTrends(for coin: Coin) async throws -> CoinWeeklyDTO {
        weeklyCallCount += 1
        weeklyStart = weeklyStart ?? Date()
        try await Task.sleep(nanoseconds: config.weeklyDelayNS)
        return try config.weeklyResult.get()
    }
    
    func fetchTodayNews(for coin: Coin) async throws -> CoinTodayNewsDTO {
        todayCallCount += 1
        todayStart = todayStart ?? Date()
        try await Task.sleep(nanoseconds: config.todayDelayNS)
        return try config.todayResult.get()
    }
    
    func setDelays(overview: UInt64, weekly: UInt64, today: UInt64) {
        config.overviewDelayNS = overview
        config.weeklyDelayNS = weekly
        config.todayDelayNS = today
    }
}

// MARK: - FetchState 테스트 헬퍼
extension FetchState {
    var isLoading: Bool { if case .loading = self { true } else { false } }
    var isSuccess: Bool { if case .success = self { true } else { false } }
    var isFailure: Bool { if case .failure = self { true } else { false } }
    var isCancel:  Bool { if case .cancel  = self { true } else { false } }
}

// MARK: - XCTestCase 비동기 대기 헬퍼
extension XCTestCase {
    /// 임의의 조건이 참이 될 때까지 주기적으로 확인합니다.
    /// - 사용처: 취소 즉시성(A), 순차 반영(B) 등 상태 전이 확인
    func XCTAssertEventuallyTrue(
        timeout: TimeInterval = 2.0,
        interval: TimeInterval = 0.02,
        _ predicate: @escaping () -> Bool
    ) async {
        let start = Date()
        while Date().timeIntervalSince(start) < timeout {
            if predicate() { return }
            try? await Task.sleep(nanoseconds: UInt64(interval * 1_000_000_000))
        }
        XCTFail("Condition not met within \(timeout)s")
    }

    /// 메인 액터에서만 접근 가능한 상태를 안전하게 확인합니다.
    /// - 사용처: @MainActor 속성(예: @Published 바인딩된 UI 상태) 검사
    func XCTAssertEventuallyTrueOnMain(
        timeout: TimeInterval = 2.0,
        interval: TimeInterval = 0.02,
        _ predicate: @MainActor @escaping () -> Bool
    ) async {
        let start = Date()
        while Date().timeIntervalSince(start) < timeout {
            let ok = await MainActor.run { predicate() }
            if ok { return }
            try? await Task.sleep(nanoseconds: UInt64(interval * 1_000_000_000))
        }
        XCTFail("Condition not met within \(timeout)s on MainActor")
    }

    /// 특정 표현식 값이 기대값과 같아질 때까지 대기합니다(Equatable 필요).
    /// - 사용처: 상태 enum 한정값 도달 등 단일 값 비교가 명확할 때
    func XCTAssertAwaitValue<T: Equatable>(
        _ expression: @escaping () -> T,
        equals expected: T,
        timeout: TimeInterval = 2.0,
        interval: TimeInterval = 0.02
    ) async {
        await XCTAssertEventuallyTrue(timeout: timeout, interval: interval) {
            expression() == expected
        }
    }

    /// 메인 액터 버전
    func XCTAssertAwaitValueOnMain<T: Equatable>(
        _ expression: @MainActor @escaping () -> T,
        equals expected: T,
        timeout: TimeInterval = 2.0,
        interval: TimeInterval = 0.02
    ) async {
        await XCTAssertEventuallyTrueOnMain(timeout: timeout, interval: interval) {
            expression() == expected
        }
    }
}
