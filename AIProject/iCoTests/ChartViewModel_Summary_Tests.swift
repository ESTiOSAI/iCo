//
//  ChartViewModel_Summary_Tests.swift
//  AIProjectTests
//
//  Created by 강민지 on 8/18/25.
//

import XCTest
@testable import iCo

/// summary(마지막가/절대변화/변화율) 계산을 검증하는 테스트
@MainActor
final class ChartViewModel_Summary_Tests: XCTestCase {
    /// 일반 케이스: 마지막가/변화/변화율이 기대값과 일치
    func test_summary_calculates_change_and_rate() throws {
        let now = Date()
        let p1 = makePrice(now, 100, 100)
        let p2 = makePrice(now.addingTimeInterval(60), 110, 125)

        let vm = ChartViewModel(coin: .init(id: "KRW-XRP", koreanName: "리플"))
        vm.prices = [p1, p2]

        let s = try XCTUnwrap(vm.summary)
        XCTAssertEqual(s.lastPrice, 125, accuracy: 1e-6)
        XCTAssertEqual(s.change,    25,  accuracy: 1e-6)
        XCTAssertEqual(s.changeRate,25.0,accuracy: 1e-6)
    }
    
    /// 데이터가 없으면 summary는 nil이어야 함
    func test_summary_isNil_whenNoData() {
        let vm = ChartViewModel(coin: .init(id: "KRW-ETH", koreanName: "이더리움"))
        vm.prices = []
        XCTAssertNil(vm.summary)
    }
    
    /// 첫 번째 종가가 0이면 0으로 나누기 방지를 위해 변화율은 0이어야 함
    func test_summary_whenFirstCloseZero_rateZero() throws {
        let now = Date()
        let vm = ChartViewModel(coin: .init(id: "KRW-ZRX", koreanName: "제로엑스"))
        vm.prices = [ makePrice(now, 0, 0),
                      makePrice(now.addingTimeInterval(10), 1, 10) ]
        let s = try XCTUnwrap(vm.summary)
        XCTAssertEqual(s.changeRate, 0, accuracy: 1e-6)
    }
}
