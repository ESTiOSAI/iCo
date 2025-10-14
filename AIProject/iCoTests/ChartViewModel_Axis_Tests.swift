//
//  ChartViewModel_Axis_Tests.swift
//  AIProjectTests
//
//  Created by 강민지 on 8/18/25.
//

import XCTest
@testable import iCo

/// 차트 X축 도메인/초기 스크롤 시각 계산을 검증하는 테스트
@MainActor
final class ChartViewModel_Axis_Tests: XCTestCase {
    /// 24h 미만(span < 24h)일 때:
    /// - xAxisDomain == first...last
    /// - scrollToTime == last
    func test_xAxisDomain_and_scrollToTime() {
        let base = Date()
        let last = base.addingTimeInterval(600) // +10분
        let data = [ makePrice(base, 100, 100),
                     makePrice(last, 110, 111) ]

        let vm = ChartViewModel(coin: .init(id: "KRW-SOL", koreanName: "솔라나"))
        
        let domain = vm.xAxisDomain(for: data)
        
        XCTAssertEqual(domain.lowerBound.timeIntervalSince1970,
                       base.timeIntervalSince1970,
                       accuracy: 1)
        XCTAssertEqual(domain.upperBound.timeIntervalSince1970,
                       last.timeIntervalSince1970,
                       accuracy: 1)
        XCTAssertEqual(vm.scrollToTime(for: data).timeIntervalSince1970,
                       last.timeIntervalSince1970,
                       accuracy: 1)
    }
    
    /// 24h 이상(span ≥ 24h)일 때:
    /// - xAxisDomain.lowerBound ≈ (now - 24h)
    /// - xAxisDomain.upperBound == (last + 5m)
    /// - scrollToTime == (last + 5m)
    func test_xAxisDomain_and_scrollToTime_whenSpanIs24hOrMore() {
        let base = Date()
        // first = base, last = base + 24h + 10m  ⇒ span ≥ 24h
        let last = base.addingTimeInterval(24*60*60 + 10*60)
        let data = [
            makePrice(base, 100, 100),
            makePrice(last, 110, 111)
        ]
        
        let vm = ChartViewModel(coin: .init(id: "KRW-SOL", koreanName: "솔라나"))
        
        // 호출 전후 now 경계 캡처
        let t0 = Date()
        let domain = vm.xAxisDomain(for: data)
        let t1 = Date()

        let expectedLowerMin = t0.addingTimeInterval(-24*60*60)
        let expectedLowerMax = t1.addingTimeInterval(-24*60*60)
        let expectedUpper    = last.addingTimeInterval(60 * 5)

        XCTAssert(domain.lowerBound >= expectedLowerMin && domain.lowerBound <= expectedLowerMax,
                  "lowerBound는 호출 시각(now) 기준 -24h 범위여야 함")
        XCTAssertEqual(domain.upperBound.timeIntervalSince1970,
                       expectedUpper.timeIntervalSince1970,
                       accuracy: 1,
                       "upperBound는 last+5m 이어야 함")
        XCTAssertEqual(vm.scrollToTime(for: data).timeIntervalSince1970,
                       expectedUpper.timeIntervalSince1970,
                       accuracy: 1,
                       "scrollToTime은 24h 이상일 때 last+5m이어야 함")
    }
}
