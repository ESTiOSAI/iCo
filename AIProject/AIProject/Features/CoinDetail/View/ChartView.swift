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
    @StateObject var viewModel: ChartViewModel
    /// 사용자 선택 기간 (현재는 1D만 표시, 나머지는 UI용)
    @State private var selectedInterval: CoinInterval = CoinInterval.all.first!
    /// 세그먼트 탭 선택 인덱스 (커스텀 SegmentedControlView와 바인딩)
    @State private var selectedTab = 0

    /// 차트 데이터 (시계열 포인트)
    private var data: [CoinPrice] { viewModel.prices }
    /// 헤더의 가격 요약 정보(마지막가 / 변화 / 등락률)
    private var summary: PriceSummary? { viewModel.summary }

    init(coin: Coin) {
        _viewModel = StateObject(wrappedValue:  ChartViewModel(coin: coin))
    }
    
    var body: some View {
        /// 차트 시계열 데이터에서 마지막 포인트 (가장 최신 데이터)
        let lastPoint = data.last

        let isRising = summary?.change ?? 0 > 0
        let isFalling = summary?.change ?? 0 < 0
        let color: Color = isRising ? .aiCoNegative :
        isFalling ? .aiCoPositive :
            .gray
        
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                
                /// 타이틀 영역: 코인명 / 심볼
                HStack(spacing: 8) {
                    Text(viewModel.coinName)
                        .font(.title3).bold()
                        .foregroundStyle(.aiCoLabel)

                    CoinLabelView(text: viewModel.coinSymbol)
                    
                    Spacer()
                    
                    /// 코인 북마크 버튼
                    /// - 현재 코인이 북마크되어 있는지 여부에 따라 아이콘 표시 변경
                    /// - 탭 시 북마크 추가/제거 로직 호출
                    Button(action: {
                        viewModel.toggleBookmark()
                    }) {
                        ZStack {
                            Circle()
                                .fill(Color(.systemGray5))
                                .frame(width: 32, height: 32)
                            Image(systemName: viewModel.isBookmarked ? "bookmark.fill" : "bookmark")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 16, height: 16)
                                .foregroundColor(.aiCoLabel)
                        }
                    }
                }

                // 상단 요약: 현재가 및 등락
                if let summary {
                    Text(summary.lastPrice.formatKRW)
                        .font(.largeTitle).bold()
                        .foregroundStyle(.aiCoLabel)
                    
                    let sign = isRising ? "+" : (isFalling ? "-" : "")
                    
                    Text("\(sign)\(abs(summary.change).formatKRW) (\(summary.changeRate.formatRate))")
                        .font(.subheadline)
                        .foregroundStyle(color)
                }
                
                let yRange = viewModel.yAxisRange(from: data)
                let xDomain = viewModel.xAxisDomain(for: data)
                let scrollTo = viewModel.scrollToTime(for: data)
                
                /// 캔들 차트: 가격 시계열을 고가/저가 선(RuleMark) + 시가/종가 직사각형(RectangleMark)으로 표현
                Chart(data) { point in
                    /// 고가/저가 수직선 표시 (위꼬리/아래꼬리 역할)
                    RuleMark(
                        x: .value("Date", point.date),
                        yStart: .value("Low", point.low),
                        yEnd: .value("High", point.high)
                    )
                    .foregroundStyle(point.close >= point.open ? .aiCoPositive : .aiCoNegative)
                    
                    /// 시가/종가 직사각형 (실체 바)
                    RectangleMark(
                        x: .value("Date", point.date),
                        yStart: .value("Open", point.open),
                        yEnd: .value("Close", point.close),
                        width: 6
                    )
                    .foregroundStyle(point.close >= point.open ? .aiCoPositive : .aiCoNegative)
                }
                .frame(height: 380)
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
                                Text(viewModel.timeFormatter.string(from: date))
                            }
                        }
                        
                        // 세로선은 1시간 단위(분 == 0)일 때만 표시
                        if let date = value.as(Date.self),
                           Calendar.current.component(.minute, from: date) == 0 {
                            AxisGridLine()
                        }
                    }
                }
                /// Y축 눈금 (20만 원 단위) + 값 포맷을 M(억) 단위로 축약
                .chartYAxis {
                    AxisMarks(values: .stride(by: 200_000)) { value in // 20만원 단위 눈금 표시
                        AxisGridLine()
                        AxisTick()
                        if let price = value.as(Double.self) {
                            AxisValueLabel {
                                Text(String(format: "%.1fM", price / 1_000_000))
                            }
                        }
                    }
                }
                /// 차트 오른쪽 영역에 여백 추가
                .chartPlotStyle { plotArea in
                    plotArea
                        .padding(.trailing, 10)
                }
                
                /// 기간 선택 탭 (UI용)
                GeometryReader { proxy in
                    SegmentedControlView(
                        selection: $selectedTab,
                        tabTitles: CoinInterval.all.map(\.id),
                        width: proxy.size.width
                    )
                    .frame(width: proxy.size.width, height: 44)
                }
                .frame(height: 44)
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            /// 뷰가 나타날 때 현재 코인의 북마크 여부 확인 (PR 테스트용으로 남겨둠, 추후 삭제 예정)
            .onAppear {
                viewModel.checkBookmark()
                do {
                    let bookmarks = try BookmarkManager.shared.fetchAll()
                    print("현재 북마크된 코인 ID 목록:")
                    for bookmark in bookmarks {
                        print(" - \(bookmark.coinID)")
                    }
                } catch {
                    print("북마크 목록 가져오기 실패: \(error)")
                }
            }
        }
        .background(.aiCoBackground)
    }
}

#Preview {
    ChartView(coin: Coin(id: "KRW-BTC", koreanName: "비트코인"))
}
