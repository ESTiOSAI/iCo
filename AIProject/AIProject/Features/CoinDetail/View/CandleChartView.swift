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
        /// 라벨과 같은 타임존의 캘린더로 틱/그리드 계산
        let timeZone  = timeFormatter.timeZone ?? .current
        let calendar = Calendar.gregorian(timeZone: timeZone)

        /// X축 틱: 항상 00/15/30/45만 생성
        let rawTicks = quarterTicksStrict(in: xDomain, calendar: calendar)

        /// 라벨 경계 버퍼
        /// 우측 경계로부터 3분 이내 라벨은 숨김 (클리핑/치우침 방지)
        let step: TimeInterval = 15 * 60
        let buffer = step * 0.2 // 15분의 20% = 3분
        
        /// 라벨 기준: 도메인 상한이 아니라 실제 보이는 오른쪽 끝 "마지막 캔들 시각"을 사용
        let lastDataX = data.last?.date ?? xDomain.upperBound
        let visibleRight = lastDataX
        
        /// 버퍼 이내(경계 근접) 라벨은 숨김
        let ticks = rawTicks.filter { $0.addingTimeInterval(buffer) <= visibleRight }
        
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
                    width: 4
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
        /// X축 눈금: 고정 틱 사용(15분 간격) + 정시에만 세로선
        .chartXAxis {
            AxisMarks(values: ticks) { value in
                AxisTick()
                if let date = value.as(Date.self) {
                    AxisValueLabel { Text(timeFormatter.string(from: date)) } // 00/15/30/45분에만 노출
                    if calendar.component(.minute, from: date) == 0 { AxisGridLine() } // 00분에만 세로 선
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
        /// 차트 오른쪽 영역에 여백 추가: 라벨/마지막 캔들 여유
        .chartPlotStyle { $0.padding(.trailing, 20).padding(.bottom, 8) }
    }
    
    // MARK: - Quarter Ticks (strict 00/15/30/45)
    /// 정각·15·30·45 분 틱 생성 (안전 처리)
    private func quarterTicksStrict(in domain: ClosedRange<Date>, calendar: Calendar) -> [Date] {
        // 시(hour) 시작 시각 계산(실패 시 합리적 폴백)
        let hourStart: Date = {
            if let interval = calendar.dateInterval(of: .hour, for: domain.lowerBound) {
                return interval.start
            } else {
                var components = calendar.dateComponents([.year, .month, .day, .hour], from: domain.lowerBound)
                components.minute = 0
                components.second = 0
                components.nanosecond = 0
                return calendar.date(from: components) ?? domain.lowerBound
            }
        }()

        var cursor = hourStart
        var ticks: [Date] = []

        while cursor <= domain.upperBound {
            for minute in [0, 15, 30, 45] {
                var components = calendar.dateComponents([.year, .month, .day, .hour], from: cursor)
                components.minute = minute
                components.second = 0
                components.nanosecond = 0

                if let tick = calendar.date(from: components), domain.contains(tick) {
                    ticks.append(tick)
                }
            }
            guard let nextHour = calendar.date(byAdding: .hour, value: 1, to: cursor) else {
                break
            }
            cursor = nextHour
        }
        return ticks.sorted()
    }
}
