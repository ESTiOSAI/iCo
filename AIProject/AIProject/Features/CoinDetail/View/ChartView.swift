//
//  CoinChartView.swift
//  AIProject
//
//  Created by 강민지 on 7/31/25.
//

import SwiftUI
import Charts

struct ChartView: View {
    @StateObject private var viewModel = ChartViewModel()
    @State private var selectedInterval: CoinInterval = .d1 // 현재는 1D만 사용 (나머지는 UI용)
    @State private var selectedTab = 0

    private var data: [CoinPrice] { viewModel.prices }
    private var summary: PriceSummary? { viewModel.summary }

    var body: some View {
        let lastPoint = data.last

        ScrollView {
            VStack(alignment: .leading, spacing: 12) {

                // 타이틀 영역
                HStack(spacing: 8) {
                    Text(viewModel.name)
                        .font(.title3).bold()
                        .foregroundStyle(.aiCoLabel)

                    Text(viewModel.symbol)
                        .font(.footnote).bold()
                        .padding(.horizontal, 10).padding(.vertical, 6)
                        .foregroundStyle(.gray)
                        .background(Capsule().fill(Color(.systemGray5)))
                }

                // 현재가 / 등락
                if let summary {
                    Text(summary.lastPrice, format: .currency(code: viewModel.currency))
                        .font(.largeTitle).bold()
                        .foregroundStyle(.aiCoLabel)

                    let sign = summary.change >= 0 ? "+" : ""
                    Text("\(sign)\(summary.change, format: .currency(code: viewModel.currency)) (\(summary.changeRate, format: .number.precision(.fractionLength(1)))%)")
                        .font(.subheadline)
                        .foregroundStyle(summary.change >= 0 ? .aiCoNegative : .aiCoPositive)
                }

                // 차트
                Chart {
                    ForEach(data) { point in
                        LineMark(
                            x: .value("Date", point.date),
                            y: .value("Close", point.close)
                        )
                    }
                    .interpolationMethod(.linear)
                    .lineStyle(.init(lineWidth: 3))
                    .foregroundStyle(.aiCoNegative)

                    if let last = lastPoint {
                        PointMark(
                            x: .value("Date", last.date),
                            y: .value("Close", last.close)
                        )
                        .symbol {
                            ZStack {
                                Circle().fill(.aiCoNegative.opacity(0.12)).frame(width: 36, height: 36)
                                Circle().fill(.aiCoNegative).frame(width: 10, height: 10)
                            }
                        }
                    }
                }
                .frame(height: 380)
                .chartXAxis(.hidden)
                .chartYAxis(.hidden)

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
