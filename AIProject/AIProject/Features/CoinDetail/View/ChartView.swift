//
//  CoinChartView.swift
//  AIProject
//
//  Created by 강민지 on 7/31/25.
//

import SwiftUI
import Charts

/// 코인 상세 화면의 가격 차트 뷰
/// `ChartViewModel`이 제공하는 시계열 데이터를 라인 차트로 렌더링
struct ChartView: View {
    /// 헤더/차트에 바인딩되는 상태를 관리하는 ViewModel
    @StateObject private var viewModel = ChartViewModel()
    /// 사용자 선택 기간 (현재는 1D만 표시, 나머지는 UI용)
    @State private var selectedInterval: CoinInterval = .d1
    /// 세그먼트 탭 선택 인덱스 (커스텀 SegmentedControlView와 바인딩)
    @State private var selectedTab = 0

    /// 차트 데이터 (시계열 포인트)
    private var data: [CoinPrice] { viewModel.prices }
    /// 헤더의 가격 요약 정보(마지막가 / 변화 / 등락률)
    private var summary: PriceSummary? { viewModel.summary }

    var body: some View {
        let lastPoint = data.last

        let isRising = summary?.change ?? 0 > 0
        let isFalling = summary?.change ?? 0 < 0
        let color: Color = isRising ? .aiCoNegative :
                           isFalling ? .aiCoPositive :
                           .gray
        
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {

                // 타이틀 영역: 코인명 / 심볼
                HStack(spacing: 8) {
                    Text(viewModel.coinName)
                        .font(.title3).bold()
                        .foregroundStyle(.aiCoLabel)

                    Text(viewModel.coinSymbol)
                        .font(.footnote).bold()
                        .padding(.horizontal, 10).padding(.vertical, 6)
                        .foregroundStyle(.gray)
                        .background(Capsule().fill(Color(.systemGray5)))
                }

                // 상단 요약: 현재가 및 등락
                if let summary {
                    Text(summary.lastPrice, format: .currency(code: viewModel.currency))
                        .font(.largeTitle).bold()
                        .foregroundStyle(.aiCoLabel)
                    
                    let sign = isRising ? "+" : (isFalling ? "-" : "")
                    
                    Text("\(sign)\(abs(summary.change), format: .currency(code: viewModel.currency)) (\(summary.changeRate, format: .number.precision(.fractionLength(1)))%)")
                        .font(.subheadline)
                        .foregroundStyle(color)
                }
                
                /// 값 차이가 작아도 차트가 납작하게 보이지 않도록 최소 높이와 여유 공간을 추가
                let minY = data.map(\.close).min() ?? 0
                let maxY = data.map(\.close).max() ?? 0
                let range = maxY - minY
                let minRange: Double = 10
                let safeRange = max(range, minRange)
                let padding = safeRange * 0.05
                let center = (minY + maxY) / 2

                /// 실제 적용할 차트 Y축 최소/최대값
                let chartMin = center - safeRange / 2 - padding
                let chartMax = center + safeRange / 2 + padding
                
                // 라인 차트: 가격 시계열 렌더링 + 마지막 포인트 하이라이트
                Chart {
                    ForEach(data) { point in
                        LineMark(
                            x: .value("Date", point.date),
                            y: .value("Close", point.close)
                        )
                    }
                    .interpolationMethod(.catmullRom)
                    .lineStyle(StrokeStyle(lineWidth: 3))
                    .foregroundStyle(color)

                    if let last = lastPoint {
                        PointMark(
                            x: .value("Date", last.date),
                            y: .value("Close", last.close)
                        )
                        .symbol {
                            ZStack {
                                Circle().fill(color.opacity(0.12)).frame(width: 36, height: 36)
                                Circle().fill(color).frame(width: 10, height: 10)
                            }
                        }
                    }
                }
                .frame(height: 380)
                .chartYScale(domain: chartMin...chartMax)
                .chartXAxis(.hidden)
                .chartYAxis(.hidden)

                // 기간 선택 탭 (UI용)
                GeometryReader { proxy in
                    SegmentedControlView(
                        selection: $selectedTab,
                        tabTitles: CoinInterval.allCases.map(\.rawValue),
                        width: proxy.size.width
                    )
                    .frame(width: proxy.size.width, height: 44)
                }
                .frame(height: 44)
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
        }
        .background(.aiCoBackground)
    }
}

#Preview {
    ChartView()
}
