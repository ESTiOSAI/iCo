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
    // MARK: - State / Env
    /// 헤더/차트에 바인딩되는 상태를 관리하는 ViewModel
    @StateObject private var viewModel: ChartViewModel
    /// 세그먼트 탭 선택 인덱스 (커스텀 SegmentedControlView와 바인딩)
    @State private var selectedTab = 0
    /// 현재 선택된 테마 정보를 가져오기 위한 전역 상태 객체
    @EnvironmentObject var themeManager: ThemeManager
    /// 시스템 앱 상태(active/inactive/background) 변화를 View에 전달하는 환경값
    @Environment(\.scenePhase) private var scenePhase

    // MARK: - Init
    init(
        coin: Coin,
        priceService: any CoinPriceProvider = UpbitPriceService(),
        tickerAPI: UpBitAPIService = UpBitAPIService()
    ) {
        _viewModel = StateObject(
            wrappedValue: ChartViewModel(
                coin: coin,
                priceService: priceService,
                tickerAPI: tickerAPI
            )
        )
    }

    // MARK: - Computed & Helpers
    private var data: [CoinPrice] { viewModel.prices }
    
    /// 뷰모델이 제공하는 기준 시각 사용 (없으면 빈 문자열)
    private var lastUpdatedText: String {
        guard let time = viewModel.lastUpdated else { return "" }
        return DateFormatter.stampYMdHmKST.string(from: time) + " 기준"
    }
    
    /// 뷰 전용 매핑 (테마/색)
    private var headerColor: Color {
        let v = viewModel.displayChangeValue
        if v > 0 { return themeManager.selectedTheme.positiveColor }
        if v < 0 { return themeManager.selectedTheme.negativeColor }
        return .gray
    }
    
    // MARK: - Body
    var body: some View {
        VStack(alignment: .leading) {
            headerView
            chartArea
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.aiCoBackground)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(.defaultGradient, lineWidth: 0.5)
        )
        .onAppear {
            viewModel.checkBookmark()
            viewModel.retry()
        }
        .onDisappear {
            viewModel.stopUpdating()
        }
        .onChange(of: scenePhase, initial: false) { _, newPhase in
            switch newPhase {
            case .active:
                viewModel.retry()
            case .background:
                viewModel.stopUpdating()
            case .inactive:
                break
            @unknown default:
                break
            }
        }
    }
    
    // MARK: - Subviews
    @ViewBuilder
    private var headerView: some View {
        if viewModel.shouldShowHeader {
            let change = viewModel.displayChangeValue
            let sign   = change > 0 ? "+" : (change < 0 ? "-" : "")
            let arrow  = change > 0 ? "▲" : (change < 0 ? "▼" : "")
            let absChange  = abs(change)
            
            /// 타이틀 영역
            HStack(alignment: .top, spacing: 8) {
                /// 기준 시간 / 현재가 / 등락가, 등락률 / 거래대금
                VStack(alignment: .leading, spacing: 8) {
                    Text(lastUpdatedText)
                        .font(.system(size: 10, weight: .regular))
                        .foregroundStyle(.aiCoLabel)
                        .lineLimit(1)
                    
                    Text(viewModel.displayLastPrice.formatKRW)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(.aiCoLabel)
                        .lineLimit(1)
                    
                    Text("\(sign)\(absChange.formatKRW) (\(arrow)\(abs(viewModel.displayChangeRate).formatRate))")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(headerColor)
                        .lineLimit(1)
                    
                    Text("거래대금 \(viewModel.headerAccTradePrice.formatMillion)")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(.aiCoLabelSecondary)
                        .lineLimit(1)
                }
                
                Spacer()
                
                /// 코인 북마크 버튼
                /// - 현재 코인이 북마크되어 있는지 여부에 따라 아이콘 표시 변경
                /// - 탭 시 북마크 추가/제거 로직 호출
                Button(action: { viewModel.toggleBookmark() }) {
                    CircleIconView(imageName: viewModel.isBookmarked ? "bookmark.fill" : "bookmark")
                }
            }
            .transition(.opacity.combined(with: .move(edge: .top)))
        }
    }
    
    @ViewBuilder
    private var chartArea: some View {
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
}

#Preview {
    ChartView(coin: Coin(id: "KRW-BTC", koreanName: "비트코인"))
        .environmentObject(ThemeManager())
}

private extension DateFormatter {
    static let stampYMdHmKST: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd HH:mm"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter
    }()
}
