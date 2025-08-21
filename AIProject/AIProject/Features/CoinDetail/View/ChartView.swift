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
    @StateObject private var viewModel: ChartViewModel
    /// 세그먼트 탭 선택 인덱스 (커스텀 SegmentedControlView와 바인딩)
    @State private var selectedTab = 0
    /// 현재 선택된 테마 정보를 가져오기 위한 전역 상태 객체
    @EnvironmentObject var themeManager: ThemeManager

    /// 차트 데이터 (시계열 포인트)
    private var data: [CoinPrice] { viewModel.prices }
    /// 헤더의 가격 요약 정보(마지막가 / 변화 / 등락률)
    private var summary: PriceSummary? { viewModel.summary }

//    init(coin: Coin) {
//        _viewModel = StateObject(wrappedValue:  ChartViewModel(coin: coin))
//    }
    
    /// PR용 테스트 (머지 전 삭제)
    init(coin: Coin, priceService: CoinPriceProvider? = nil) {
        if let ps = priceService {
            _viewModel = StateObject(wrappedValue: ChartViewModel(coin: coin, priceService: ps))
        } else {
            _viewModel = StateObject(wrappedValue: ChartViewModel(coin: coin))
        }
    }

    private static let headerDateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy.MM.dd HH:mm"
//        f.locale = Locale(identifier: "ko_KR")
        return f
    }()
    
    /// 뷰모델이 제공하는 기준 시각 사용 (없으면 빈 문자열)
    private var lastUpdatedText: String {
        guard let time = viewModel.lastUpdated else { return "" }
        return Self.headerDateFormatter.string(from: time) + " 기준"
    }
    
    /// 헤더는 성공 상태이면서 기준 시각이 있을 때만 보이도록 (깜빡임/오표시 방지)
    private var headerOpacity: Double {
        if case .success = viewModel.status, viewModel.lastUpdated != nil {
            return 1
        }
        return 0
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            /// 타이틀 영역
            HStack(alignment: .top, spacing: 8) {
                /// 기준 시간 / 현재가 / 등락가, 등락률 / 거래대금
                VStack(alignment: .leading, spacing: 8) {
                    Text(lastUpdatedText)
                        .font(.system(size: 10, weight: .regular))
                        .foregroundStyle(.aiCoLabel)
                        .lineLimit(1)
                        .opacity(headerOpacity)
                    
                    // 헤더 표시 조건:
                    // - Ticker 기반 값이 도착했으면(summary 유무와 무관하게) 헤더를 보여줌
                    // - Ticker도 실패하고 summary도 없으면 숨김(초기 로딩/취소/실패 시 깜빡임 방지)
                    let hasHeader = (viewModel.headerLastPrice != 0) || (summary != nil)
                    
                    /// 헤더 표기는 목록 화면과 동일 정의를 위해 Ticker 기반 값을 우선 사용
                    /// (Ticker 실패 시 summary)
                    let lastPrice   = viewModel.headerLastPrice != 0 ? viewModel.headerLastPrice : (summary?.lastPrice ?? 0)
                    let changeValue = viewModel.headerLastPrice != 0 ? viewModel.headerChangePrice  : (summary?.change ?? 0)
                    let changeRate  = viewModel.headerLastPrice != 0 ? viewModel.headerChangeRate : (summary?.changeRate ?? 0)
                    let trade = viewModel.headerAccTradePrice
                    
                    let isRising = changeValue > 0
                    let isFalling = changeValue < 0
                    let color: Color = isRising ? themeManager.selectedTheme.positiveColor :
                    isFalling ? themeManager.selectedTheme.negativeColor :
                        .gray
                    let sign = isRising ? "+" : (isFalling ? "-" : "")
                    let arrow = isRising ? "▲" : (isFalling ? "▼" : "")
                    
                    Text(lastPrice.formatKRW)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(.aiCoLabel)
                        .lineLimit(1)
                        .opacity(hasHeader ? 1 : 0)
                    
                    Text("\(sign)\(abs(changeValue).formatKRW) (\(arrow)\(abs(changeRate).formatRate))")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(color)
                        .lineLimit(1)
                        .opacity(hasHeader ? 1 : 0)
                    
                    Text("거래대금 \(trade.formatMillion)")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(.aiCoLabelSecondary)
                        .lineLimit(1)
                        .opacity(hasHeader ? 1 : 0)
                }
                
                Spacer()
                
                /// 코인 북마크 버튼
                /// - 현재 코인이 북마크되어 있는지 여부에 따라 아이콘 표시 변경
                /// - 탭 시 북마크 추가/제거 로직 호출
                Button(action: {
                    viewModel.toggleBookmark()
                }) {
                    CircleIconView(imageName: viewModel.isBookmarked ? "bookmark.fill" : "bookmark")
                }
            }
                        
            ZStack {
                switch viewModel.status {
                case .loading:
                    DefaultProgressView(
                        status: .loading,
                        message: "차트를 불러오는 중이에요"
                    ) { viewModel.cancelLoading() }
                case .failure(let err):
                    DefaultProgressView(
                        status: .failure,
                        message: err.localizedDescription
                    ) { viewModel.retry() }
                    
                case .cancel(let err):
                    DefaultProgressView(
                        status: .cancel,
                        message: err.localizedDescription
                    ) { viewModel.retry() }
                    
                case .success:
                    if data.isEmpty {
                        DefaultProgressView(
                            status: .failure,
                            message: "최근 24시간 체결 데이터가 없어요"
                        ) { viewModel.retry() }
                    } else {
                        let yRange = viewModel.yAxisRange(from: data)
                        let xDomain = viewModel.xAxisDomain(for: data)
                        let scrollTo = viewModel.scrollToTime(for: data)
                        
                        /// 캔들 차트: 가격 시계열을 고가/저가 선(RuleMark) + 시가/종가 직사각형(RectangleMark)으로 표현
                        CandleChartView(
                            data: data,
                            xDomain: xDomain,
                            yRange: yRange,
                            scrollTo: scrollTo,
                            timeFormatter: viewModel.timeFormatter,
                            positiveColor: themeManager.selectedTheme.positiveColor,
                            negativeColor: themeManager.selectedTheme.negativeColor
                        )
                    }
                }
            }
            .padding(.top, 40)
            .padding(.bottom, 20)
            .frame(height: 380)
        }
        .padding(20)
        .onAppear {
            viewModel.checkBookmark()
        }
        .onDisappear {
            viewModel.stopUpdating()
        }
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.aiCoBackground)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(.defaultGradient, lineWidth: 0.5)
        )
    }
}

//#Preview {
//    ChartView(coin: Coin(id: "KRW-BTC", koreanName: "비트코인"))
//        .environmentObject(ThemeManager())
//}

/// PR용 테스트 (머지 전 삭제)
#Preview("성공(5초 지연)") {
    ChartView(
        coin: Coin(id: "KRW-BTC", koreanName: "비트코인"),
        priceService: FakePriceService(mode: .success(delaySec: 5, points: 200))
    )
    .environmentObject(ThemeManager())
}

//#Preview("취소 동작 확인") {
//    ChartView(
//        coin: Coin(id: "KRW-BTC", koreanName: "비트코인"),
//        priceService: FakePriceService(mode: .success(delaySec: 10))
//    )
//    .environmentObject(ThemeManager())
//    // 프리뷰 실행 후 2~3초 내 ‘작업 취소’ 버튼 눌러 상태 전환 확인
//}

//#Preview("실패 동작 확인") {
//    ChartView(
//        coin: Coin(id: "KRW-BTC", koreanName: "비트코인"),
//        priceService: FakePriceService(mode: .failure(delaySec: 2))
//    )
//    .environmentObject(ThemeManager())
//}

//#Preview("빈 데이터 동작 확인") {
//    ChartView(
//        coin: Coin(id: "KRW-BTC", koreanName: "비트코인"),
//        priceService: FakePriceService(mode: .empty(delaySec: 2))
//    )
//    .environmentObject(ThemeManager())
//}

struct CandleChartView: View {
    let data: [CoinPrice]
    let xDomain: ClosedRange<Date>
    let yRange: ClosedRange<Double>
    let scrollTo: Date
    let timeFormatter: DateFormatter
    let positiveColor: Color
    let negativeColor: Color
    private let barWidth: CGFloat = 6
    
    var body: some View {
        Chart(data) { point in
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
