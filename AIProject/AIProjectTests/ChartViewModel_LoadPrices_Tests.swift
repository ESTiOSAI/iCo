//
//  ChartViewModel_LoadPrices_Tests.swift
//  AIProjectTests
//
//  Created by 강민지 on 8/18/25.
//

import XCTest
@testable import AIProject

/// loadPrices의 시간 필터링과 인덱스 재매핑(0..N)을 검증하는 테스트
@MainActor
final class ChartViewModel_LoadPrices_Tests: XCTestCase {
    func test_loadPrices_filters_recent_window_and_reindexes() async {
        /// now는 테스트 시작 시각으로 고정해두고, 경계에서 1~2분 여유를 둠
        let now = Date()
        let start = now.addingTimeInterval(-24 * 60 * 60)

        let outsideBefore = makePrice(start.addingTimeInterval(-600), 100, 100) // -10분: 제외
        let inside1 = makePrice(start.addingTimeInterval( 120), 100, 101) // +2분: 포함
        let inside2 = makePrice(start.addingTimeInterval(3600), 101, 103) // +1시간: 포함
        let inside3 = makePrice(now.addingTimeInterval(-120), 150, 155)   // -2분: 포함
        let future = makePrice(now.addingTimeInterval( 600), 160, 170)   // +10분: 제외(<= now)

        let mock = MockPriceProvider()
        mock.result = [outsideBefore, inside1, inside2, inside3, future]

        let vm = ChartViewModel(coin: .init(id: "KRW-BTC", koreanName: "비트코인"),
                                priceService: mock)

        await vm.loadPrices()

        // 포함된 항목만, 원래 시간 순서 보존
        XCTAssertEqual(vm.prices.map(\.date), [inside1.date, inside2.date, inside3.date])
        
        // ViewModel에서 0..N으로 재매핑되었는지 확인
        XCTAssertEqual(vm.prices.map(\.index), [0, 1, 2])
    }

    /// fetch 실패 시 빈 배열로 안전하게 초기화되는지 검증
    func test_loadPrices_onFailure_setsEmpty() async {
        enum Dummy: Error { case boom }
        let mock = MockPriceProvider()
        mock.error = Dummy.boom

        let vm = ChartViewModel(coin: .init(id: "KRW-BTC", koreanName: "비트코인"), priceService: mock)

        await vm.loadPrices()
        XCTAssertTrue(vm.prices.isEmpty)
    }
}
