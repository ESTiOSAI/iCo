//
//  ReportViewModelCancellationTests.swift
//  AIProjectTests
//
//  Created by 장지현 on 8/19/25.
//

import XCTest
@testable import iCo

final class ReportViewModelCancellationTests: XCTestCase {
    private var spy: SpyLLMAPIService!
    private var sut: ReportViewModel!
    
    private func makeSUT() -> ReportViewModel {
        ReportViewModel(coin: TestFixtures.Coin.btc, llmService: spy)
    }
    
    override func setUpWithError() throws {
        spy = SpyLLMAPIService()
        sut = self.makeSUT()
    }

    override func tearDownWithError() throws {
        spy = nil
        sut = nil
    }
    
    // MARK: - A. cancelAll
    @MainActor
    func testCancelAll_whenCalled_TaskCancelledImmediately() async {
        // Arrange
        spy.config.overviewResult = .success(TestFixtures.Overview.sample)
        spy.config.weeklyResult = .success(TestFixtures.Weekly.sample)
        spy.config.todayResult = .success(TestFixtures.TodayNews.withArticles(1))
        spy.setDelays(overview: 100_000_000, weekly: 100_000_000, today: 100_000_000)
        
        Task { @MainActor in
            await self.sut.startIfNeeded()
        }
        await XCTAssertEventuallyTrue {
            self.spy.overviewCallCount == 1 &&
            self.spy.weeklyCallCount == 1 &&
            self.spy.todayCallCount == 1
        }
        
        // Act
        sut.cancelAll()
        
        // Assert
        await XCTAssertEventuallyTrueOnMain { self.sut.overview.isCancel }
        await XCTAssertEventuallyTrueOnMain { self.sut.weekly.isCancel }
        await XCTAssertEventuallyTrueOnMain { self.sut.today.isCancel }
    }

    // MARK: - B. Individual Cancellation / Retry
    @MainActor
    func testCancelWeekly_whenCalled_onlyWeeklyCancelledOthersRemainLoading() async {
        // Arrange
        spy.config.overviewResult = .success(TestFixtures.Overview.sample)
        spy.config.weeklyResult = .success(TestFixtures.Weekly.sample)
        spy.config.todayResult = .success(TestFixtures.TodayNews.withArticles(1))
        spy.setDelays(overview: 100_000_000, weekly: 100_000_000, today: 100_000_000)
        
        Task { @MainActor in
            await sut.startIfNeeded()
        }
        await XCTAssertEventuallyTrue {
            self.spy.overviewCallCount == 1 &&
            self.spy.weeklyCallCount == 1 &&
            self.spy.todayCallCount == 1
        }
        
        // Act
        sut.cancelWeekly()

        // Assert
        await XCTAssertEventuallyTrueOnMain { self.sut.weekly.isCancel }
        XCTAssertTrue(sut.overview.isLoading)
        XCTAssertTrue(sut.today.isLoading)
    }

    @MainActor
    func testRetryToday_afterCancel_transitionsToLoadingThenSuccess() async {
        // Arrange
        spy.config.todayResult = .success(TestFixtures.TodayNews.withArticles(3))
        spy.setDelays(overview: 100_000_000, weekly: 100_000_000, today: 100_000_000)
        
        Task { @MainActor in
            await self.sut.startIfNeeded()
        }
        await XCTAssertEventuallyTrue {
            self.spy.overviewCallCount == 1 &&
            self.spy.weeklyCallCount == 1 &&
            self.spy.todayCallCount == 1
        }
        
        // Act
        sut.cancelToday()
        await XCTAssertEventuallyTrueOnMain { self.sut.today.isCancel }

        sut.retryToday()

        // Assert
        await XCTAssertAwaitValueOnMain({ self.sut.today.isLoading }, equals: true)
        await XCTAssertEventuallyTrueOnMain { self.sut.today.isSuccess }
        XCTAssertFalse(sut.news.isEmpty)
    }

    @MainActor
    func testRetryOverview_whileLoading_isIgnored() async {
        // Arrange
        spy.config.overviewResult = .success(TestFixtures.Overview.sample)
        spy.config.weeklyResult = .success(TestFixtures.Weekly.sample)
        spy.config.todayResult = .success(TestFixtures.TodayNews.withArticles(1))
        spy.setDelays(overview: 100_000_000, weekly: 100_000_000, today: 100_000_000)
        
        Task { @MainActor in
            await self.sut.startIfNeeded()
        }
        await XCTAssertEventuallyTrue { self.spy.overviewCallCount == 1 }
        await XCTAssertEventuallyTrueOnMain { self.sut.overview.isLoading }
        
        let callsBefore = spy.overviewCallCount
        
        // Act
        sut.retryOverview()

        // Assert
        XCTAssertEqual(spy.overviewCallCount, callsBefore)
        await XCTAssertEventuallyTrueOnMain { self.sut.overview.isLoading }
    }

    // MARK: - C. deinit
    @MainActor
    func testDeinit_whenSUTReleased_instanceIsReleased() async {
        // Arrange
        weak var weakVM: ReportViewModel?
        var local: ReportViewModel? = makeSUT()
        weakVM = local

        await local?.startIfNeeded()
        await XCTAssertEventuallyTrue {
            self.spy.overviewCallCount == 1 &&
            self.spy.weeklyCallCount == 1 &&
            self.spy.todayCallCount == 1
        }

        // Act
        local?.cancelAll()
        local = nil

        // Assert
        await XCTAssertEventuallyTrueOnMain(timeout: 2.0) { weakVM == nil }
    }
}
