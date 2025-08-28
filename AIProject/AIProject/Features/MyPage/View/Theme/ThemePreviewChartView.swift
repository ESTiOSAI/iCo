//
//  ThemePreviewChartView.swift
//  AIProject
//
//  Created by 강민지 on 8/27/25.
//

import SwiftUI
import Charts

/// 단일 캔들(몸통+꼬리)을 그리는 마크
@ChartContentBuilder
private func candleMark(
    _ price: CoinPrice,
    theme: Theme,
    widthSec: TimeInterval,
    wickWidthSec: TimeInterval
) -> some ChartContent {
    let isUp = price.close >= price.open
    let color = isUp ? theme.positiveColor : theme.negativeColor
    let bodyMin = min(price.open, price.close)
    let bodyMax = max(price.open, price.close)
    
    // 꼬리 길이 (몸통 대비 20% 이내로 제한)
    let bodyH = max(bodyMax - bodyMin, 0.001)
    let maxWickLen = max(0.04, bodyH * 0.20)
    let wickHigh = min(price.high, bodyMax + maxWickLen)
    let wickLow  = max(price.low,  bodyMin - maxWickLen)
    
    // 시간 기반 폭 (몸통/꼬리 두께)
    let halfCandle = widthSec / 2
    let halfWick   = wickWidthSec / 2
    
    // 꼬리 (위아래 라인)
    RectangleMark(
        xStart: .value("Time", price.date.addingTimeInterval(-halfWick)),
        xEnd:   .value("Time", price.date.addingTimeInterval(+halfWick)),
        yStart: .value("Price", wickLow),
        yEnd:   .value("Price", wickHigh)
    )
    .foregroundStyle(color)
    
    // 몸통 (실제 캔들 영역)
    RectangleMark(
        xStart: .value("Time", price.date.addingTimeInterval(-halfCandle)),
        xEnd:   .value("Time", price.date.addingTimeInterval(+halfCandle)),
        yStart: .value("Price", bodyMin),
        yEnd:   .value("Price", bodyMax)
    )
    .foregroundStyle(color)
}

/// 캔들 차트 프리뷰 뷰 (테마 색상 변경 미리보기용)
struct CandlestickPreviewView: View {
    @EnvironmentObject var themeManager: ThemeManager
    
    /// 더미 데이터 (24시간, 1분 단위)
    @State private var prices: [CoinPrice] =
    ChartViewModel.makeDummyPrices(hours: 24, samplingInterval: 60)
    
    var body: some View {
        let theme = themeManager.selectedTheme
        
        VStack(spacing: 8) {
            chartView(theme: theme)
                .frame(height: 220)
        }
        .padding(16)
        .background(.aiCoBackground)
        .overlay(RoundedRectangle(cornerRadius: 20).strokeBorder(.defaultGradient, lineWidth: 0.5))
        .padding(.horizontal, 16)
    }
    
    /// 캔들스틱 차트를 그리는 뷰 (최근 24개 봉만)
    @ViewBuilder
    private func chartView(theme: Theme) -> some View {
        // 보여지는 캔들 바 갯수
        let visiblePrices = Array(prices.suffix(36))
        
        if visiblePrices.count < 2 {
            Color.clear
        } else {
            let first = visiblePrices.first!
            let last  = visiblePrices.last!
            let interval = visiblePrices[1].date.timeIntervalSince(visiblePrices[0].date)
            
            // 간단한 튜닝: 몸통/꼬리 두께 비율
            let candleWidthSec = interval * 0.55
            let wickWidthSec   = max(interval * 0.15, 0.7)
            
            // X축 도메인: 양 끝에 반 간격 여유
            let domainStart = first.date.addingTimeInterval(-interval * 0.5)
            let domainEnd   = last.date.addingTimeInterval( +interval * 0.5)

            let minLow  = visiblePrices.map(\.low).min()!
            let maxHigh = visiblePrices.map(\.high).max()!
            let yPad = max((maxHigh - minLow) * 0.03, 0.01)   // 아주 얕은 패딩

            
            Chart {
                ForEach(visiblePrices, id: \.index) { price in
                    candleMark(price,
                               theme: theme,
                               widthSec: candleWidthSec,
                               wickWidthSec: wickWidthSec)
                }
            }
            .chartXAxis(.hidden)
            .chartYAxis(.hidden)
            .chartXScale(domain: domainStart...domainEnd)
            .chartYScale(domain: (minLow - yPad)...(maxHigh + yPad))
        }
    }
}
