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
    /// 화면 간격에 맞춰 계산된 캔들 바 폭(pt)
    /// `recalcWidth(_:)`에서 갱신되며 기본값 4pt는 초기 렌더용
    @State private var candleWidth: CGFloat = 4
    /// 현재 가시 X 구간의 중심(스크롤 위치 바인딩)
    @State private var centerOfVisibleXRange: Date
    /// 동적으로 계산된 Y 도메인 (없으면 yRange 폴백)
    @State private var dynamicVisibleYDomain: ClosedRange<Double>? = nil
    /// 디바운스용 워크아이템 (중복 실행 / 레이스 방지)
    @State private var yAxisRecalcWorkItem: DispatchWorkItem?
    /// 플롯 높이 (픽셀 → 데이터 단위 환산에 필요)
    @State private var plotHeight: CGFloat = 1

    /// 한 화면에 보여줄 X 구간 (초) -  48분
    private let visibleLengthInSeconds: TimeInterval = 48 * 60
    /// 초기 오른쪽 여백 (초) - 마지막 봉 기준 5분
    private let initialRightPadding: TimeInterval = 5 * 60
    /// Y 계산 시 우측 1분, 좌측 30초 만큼 구간 확장
    private let yLookahead: TimeInterval = 60
    private let yLookbehind: TimeInterval = 30
    
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
                    width: .fixed(candleWidth)
                )
                .foregroundStyle( point.close >= point.open ? positiveColor : negativeColor )
            }
        }
        /// 플롯 크기/스케일 변화 시 캔들 폭 재계산
        .chartOverlay { proxy in
          GeometryReader { _ in
            Color.clear
              .onAppear { recalcWidth(proxy) }
              .onChange(of: proxy.plotSize) { _, _ in recalcWidth(proxy) }
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
    
    // MARK: - Y 스케일 계산 (디바운스)
    /// 디바운스 스케줄러: 빠른 스크롤 중엔 재계산을 미루고,
    /// 사용자가 잠깐 멈추면 한 번만 실행하여 깜빡임/부하를 줄임
    private func scheduleYAxisRecalcDebounced() {
        yAxisRecalcWorkItem?.cancel()
        
        let work = DispatchWorkItem {
            self.recalcVisibleYAxisDomain()
            
            // 관성으로 더 움직인 경우를 커버하기 위해 80ms 뒤 한 번 더 재계산
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) {
                self.recalcVisibleYAxisDomain()
            }
        }
        
        yAxisRecalcWorkItem = work
        
        // 사용자가 잠깐 멈출 때 한 번만 실행되도록 0.12초 지연
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.12, execute: work)
    }
    
    // MARK: - Y 스케일 실제 재계산
    private func recalcVisibleYAxisDomain() {
        guard !data.isEmpty else {
            dynamicVisibleYDomain = yRange
            return
        }

        // 현재 X 가시 구간 (중심±길이/2)
        let windowCenter = centerOfVisibleXRange
        let windowStart  = windowCenter.addingTimeInterval(-visibleLengthInSeconds / 2)
        let windowEnd    = windowCenter.addingTimeInterval( visibleLengthInSeconds / 2)

        // 오른쪽으로 1분, 왼쪽으로 30초 확장해서 스캔
        let yStart = windowStart.addingTimeInterval(-yLookbehind)
        let yEnd   = windowEnd.addingTimeInterval(  yLookahead)

        // 현재 보이는 구간의 캔들만 추출
        let visibleCandles = data.lazy.filter { $0.date >= yStart && $0.date <= yEnd }

        guard let minPrice = visibleCandles.map(\.low).min(),
              let maxPrice = visibleCandles.map(\.high).max()
        else { dynamicVisibleYDomain = yRange; return }

        // 여유 폭 계산
        let rawRange = maxPrice - minPrice // 보이는 캔들의 순수 고저 폭
        let safeRange = max(rawRange, 10) // 너무 좁을 때 최소 폭 10 보장
        let padding = safeRange * 0.20 // 위/아래 20% 여유
        
        // pt → 데이터 환산 (현재 도메인 + 여유 패딩으로 계산)
        let proposedSpan = (maxPrice - minPrice) + 2 * padding
        let unitsPerPt   = proposedSpan / Double(max(plotHeight, 1))

        // 꼭대기 잘림 방지 여유
        let pixelGuard   = unitsPerPt * 6.0
        // 변동폭 대비 최소 비율 가드 (매우 좁은 구간 보정)
        let relativeGuard = 0.003 * max(1, rawRange)
        // 둘 중 큰 값 채택 -> 어떤 상황에서도 최소한의 여유 확보
        let guardBand = max(pixelGuard, relativeGuard)

        // Y 도메인 재계산
        let nextLower = minPrice - padding - guardBand
        let nextUpper = maxPrice + padding + guardBand
        dynamicVisibleYDomain = nextLower ... nextUpper
    }
    
    /// 현재 X축 스케일을 기반으로 캔들 바 폭을 재계산.
    private func recalcWidth(_ proxy: ChartProxy) {
        // 현재 축 스케일에서 "1분"이 화면상 몇 pt 인지 측정
        guard let last = data.last?.date, // 마지막 캔들 시각
              let prev = Calendar.current.date(byAdding: .minute, value: -1, to: last), // 마지막 캔들 - 1분 전 시각
              let x2 = proxy.position(forX: last),
              let x1 = proxy.position(forX: prev) else { return }

      // 화면 좌표에서 두 시점의 X 위치를 얻어 1분 간격 픽셀 폭 계산
      let spacing = abs(x2 - x1)
      // 그 중 60%만 막대 폭으로 사용 → 막대 사이 여백 확보
      let target  = spacing * 0.6
        
      // 겹침 방지 클램프: 최소 1pt, 최대 (spacing - 1pt)로 제한해 항상 여백 유지
      let clamped = max(1, min(target, spacing - 1))

      DispatchQueue.main.async {
        candleWidth = clamped
      }
    }

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
