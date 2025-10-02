//
//  CoinDetailView.swift
//  AIProject
//
//  Created by 장지현 on 7/31/25.
//

/// 코인 상세 화면을 표시하는 뷰입니다.
///
/// 차트(`ChartView`)와 AI 리포트(`ReportView`)를 탭으로 전환하여 볼 수 있습니다.
/// - Regular size class: 차트와 리포트를 동시에 표시
/// - Compact size class: 탭 전환 방식으로 표시
import SwiftUI

struct CoinDetailView: View {
    @Environment(\.horizontalSizeClass) var hSizeClass
    @Environment(\.dismiss) var dismiss
    
    @StateObject var reportViewModel: ReportViewModel
    
    @State private var selectedTab: Tab = .chart
    @State private var baseHeight: CGFloat?
    @State private var isKeyboardVisible = false
    @State private var keyboardObserver: NSObjectProtocol?
    
    let coin: Coin
    
    var onNewlyListedChange: (Bool) -> Void = { _ in }
    
    init(coin: Coin, onNewlyListedChange: @escaping (Bool) -> Void = { _ in }) {
        self.coin = coin
        self.onNewlyListedChange = onNewlyListedChange
        _reportViewModel = StateObject(wrappedValue: ReportViewModel(coin: coin))
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            GeometryReader { proxy in
                let containerHeight = baseHeight ?? proxy.size.height
                
                ScrollView {
                    VStack(spacing: 0) {
                        VStack(spacing: 16) {
                            tabButtons
                            content(containerHeight: containerHeight)
                        }
                        .padding(.horizontal, 16)
                        .onAppear {
                            if baseHeight == nil { baseHeight = proxy.size.height }
                        }
                    }
                }
                .scrollIndicators(.hidden)
            }
        }
        .onDisappear {
            reportViewModel.cancelAll()
        }
        .interactiveSwipeBackEnabled()
    }
}

// MARK: - Subviews (Buttons, Content)
extension CoinDetailView {
    /// compact size class에서 차트/리포트 탭 전환 버튼을 표시합니다.
    @ViewBuilder
    fileprivate var tabButtons: some View {
        if hSizeClass == .compact {
            HStack(spacing: 16) {
                ForEach(Tab.allCases) { tab in
                    RoundedRectangleButton(
                        title: tab.title,
                        isActive: selectedTab == tab
                    ) {
                        withAnimation(.easeInOut(duration: 0.22)) {
                            selectedTab = tab
                        }
                    }
                }
                Spacer(minLength: 0)
            }
        }
    }
    
    /// 차트와 리포트 콘텐츠를 표시하는 뷰입니다.
    ///
    /// - Regular size class: 차트와 리포트를 모두 표시
    /// - Compact size class: 탭 선택에 따라 하나씩 표시
    @ViewBuilder
    fileprivate func content(containerHeight: CGFloat) -> some View {
        if hSizeClass == .regular {
            ChartView(coin: coin, onNewlyListedChange: onNewlyListedChange)
                .frame(height: containerHeight * Layout.regularChartRatio)
            
            ReportView(viewModel: reportViewModel)
                .padding(.top, 20)
        } else {
            switch selectedTab {
            case .chart:
                ChartView(coin: coin, onNewlyListedChange: onNewlyListedChange)
                    .frame(height: containerHeight * Layout.compactChartRatio)
            case .report:
                ReportView(viewModel: reportViewModel)
            }
        }
    }
}

// MARK: - Tab
extension CoinDetailView {
    /// 코인 상세 화면의 하위 탭 종류입니다.
    ///
    /// - chart: 시세 차트
    /// - report: AI 리포트
    private enum Tab: Int, CaseIterable, Identifiable {
        case chart
        case report
        
        var id: Int { rawValue }
        
        var title: String {
            switch self {
            case .chart: return "시세"
            case .report: return "AI 리포트"
            }
        }
    }
}

// MARK: - Layout Constants
extension CoinDetailView {
    /// 레이아웃 관련 상수를 정의한 열거형입니다.
    ///
    /// 차트 높이 비율은 size class에 따라 다르게 적용됩니다.
    private enum Layout {
        static let regularChartRatio: CGFloat = 0.55
        static let compactChartRatio: CGFloat = 0.8
    }
}

#Preview {
    let sampleCoin = Coin(id: "KRW-BTC", koreanName: "비트코인")
    CoinDetailView(coin: sampleCoin)
        .environmentObject(ThemeManager())
}
