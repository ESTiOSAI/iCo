//
//  ChartView+Previews.swift
//  AIProject
//
//  Created by 강민지 on 8/21/25.
//

#if DEBUG
import SwiftUI

extension Coin {
    static let previewBTC = Coin(id: "KRW-BTC", koreanName: "비트코인")
}

#Preview("성공(5초 지연)") {
    ChartView(
        coin: Coin(id: "KRW-BTC", koreanName: "비트코인"),
        priceService: PreviewPriceService(mode: .success(delaySec: 5, points: 200))
    )
    .environmentObject(ThemeManager())
}

#Preview("취소 동작 확인") {
    ChartView(
        coin: Coin(id: "KRW-BTC", koreanName: "비트코인"),
        priceService: PreviewPriceService(mode: .success(delaySec: 10))
    )
    .environmentObject(ThemeManager())
    // 프리뷰 실행 후 2~3초 내 ‘작업 취소’ 버튼 눌러 상태 전환 확인
}

#Preview("실패 동작 확인") {
    ChartView(
        coin: Coin(id: "KRW-BTC", koreanName: "비트코인"),
        priceService: PreviewPriceService(mode: .failure(delaySec: 2))
    )
    .environmentObject(ThemeManager())
}

#Preview("빈 데이터 동작 확인") {
    ChartView(
        coin: Coin(id: "KRW-BTC", koreanName: "비트코인"),
        priceService: PreviewPriceService(mode: .empty(delaySec: 2))
    )
    .environmentObject(ThemeManager())
}
#endif
