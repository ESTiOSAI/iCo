//
//  CandleChartView.swift
//  AIProject
//
//  Created by 강민지 on 8/25/25.
//

import SwiftUI
import Charts

/// 캔들 차트: 가격 시계열을 고가/저가 선(RuleMark) + 시가/종가 직사각형(RectangleMark)으로 표현
struct CandleChartView: View {
    let data: [CoinPrice]
    let xDomain: ClosedRange<Date>
    let yRange: ClosedRange<Double>
    let scrollTo: Date
    let timeFormatter: DateFormatter
    let positiveColor: Color
    let negativeColor: Color
    
    var body: some View {
        Chart {
            ForEach(data, id: \.date) { point in
                /// 고가/저가 수직선 표시 (위꼬리/아래꼬리 역할)
                RuleMark(
                    x: .value("Date", point.date),
                    yStart: .value("Low", point.low),
                    yEnd: .value("High", point.high)
                )
                .foregroundStyle( point.close >= point.open ? positiveColor : negativeColor )
                
                /// 시가/종가 직사각형 (실체 바)
                RectangleMark(
                    x: .value("Date", point.date),
                    yStart: .value("Open", point.open),
                    yEnd: .value("Close", point.close),
                    width: 6
                )
                .foregroundStyle( point.close >= point.open ? positiveColor : negativeColor )
            }
        }
        /// X축 도메인 설정 및 스크롤 위치 초기화
        .chartXScale(domain: xDomain)
        .chartScrollPosition(initialX: scrollTo)
        .chartScrollableAxes(.horizontal)
        /// Y축 도메인 설정 (동적 범위)
        .chartYScale(domain: yRange)
        /// 한 화면에서 보이는 X축 범위 (2880초 = 48분)
        .chartXVisibleDomain(length: 2880)
        /// X축 눈금 (15분 간격) + 1시간마다 세로선 표시
        .chartXAxis {
            AxisMarks(values: .stride(by: .minute, count: 15)) { value in
                AxisTick()
                AxisValueLabel {
                    if let date = value.as(Date.self) {
                        Text(timeFormatter.string(from: date))
                    }
                }
                
                /// 세로선은 1시간 단위(분 == 0)일 때만 표시
                if let date = value.as(Date.self),
                   Calendar.current.component(.minute, from: date) == 0 {
                    AxisGridLine()
                }
            }
        }
        .chartYAxis {
            AxisMarks { value in
                AxisGridLine()
                AxisTick()
                if let v = value.as(Double.self) {
                    AxisValueLabel {
                        if yRange.upperBound >= 1_000_000 {
                            Text(String(format: "%.1fM", v / 1_000_000)) // 백만 단위
                        } else if yRange.upperBound >= 1_000 {
                            Text(String(format: "%.1fK", v / 1_000)) // 천 단위
                        } else {
                            Text(String(format: "%.0f", v)) // 원 단위 그대로
                        }
                    }
                }
            }
        }
        /// 차트 오른쪽 영역에 여백 추가
        .chartPlotStyle { $0.padding(.trailing, 10).padding(.bottom, 8) }
    }
}
