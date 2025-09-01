//
//  ChartViewModel_Axis_Tests.swift
//  AIProjectTests
//
//  Created by 강민지 on 8/18/25.
//

import XCTest
@testable import AIProject

/// 차트 X축 도메인/초기 스크롤 시각 계산을 검증하는 테스트
/// - 핵심: 상한은 "마지막 데이터 +5분"과 정확히 일치해야 하며,
///       하한은 내부에서 Date()를 사용하는 특성상 (호출 시각 t0~t1) 사이의 -24h 범위여야 함.
@MainActor
final class ChartViewModel_Axis_Tests: XCTestCase {
    func test_xAxisDomain_and_scrollToTime() {
        let base = Date()
        let last = base.addingTimeInterval(600) // +10분
        let data = [ makePrice(base, 100, 100),
                     makePrice(last, 110, 111) ]

        let vm = ChartViewModel(coin: .init(id: "KRW-SOL", koreanName: "솔라나"))

        // 호출 전후 now 경계 캡처
        let t0 = Date()
        let domain = vm.xAxisDomain(for: data)
        let t1 = Date()

        let expectedLowerMin = t0.addingTimeInterval(-24*60*60)
        let expectedLowerMax = t1.addingTimeInterval(-24*60*60)
        let expectedUpper    = last.addingTimeInterval(60 * 5)

        XCTAssert(domain.lowerBound >= expectedLowerMin && domain.lowerBound <= expectedLowerMax,
                  "lowerBound이 호출 시각 기준 24h 윈도우와 일치해야 함")
        XCTAssertEqual(domain.upperBound.timeIntervalSince1970, expectedUpper.timeIntervalSince1970, accuracy: 1)

        // 초기 스크롤 지점은 마지막 데이터 +5분
        XCTAssertEqual(vm.scrollToTime(for: data).timeIntervalSince1970,
                       expectedUpper.timeIntervalSince1970,
                       accuracy: 1)
    }
}
