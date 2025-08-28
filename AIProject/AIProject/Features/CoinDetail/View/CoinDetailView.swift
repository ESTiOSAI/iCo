//
//  CoinDetailView.swift
//  AIProject
//
//  Created by 장지현 on 7/31/25.
//

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
    let onDismiss: (() -> Void)?
    
    init(coin: Coin, onDismiss: (() -> Void)? = nil) {
        self.coin = coin
        self.onDismiss = onDismiss
        _reportViewModel = StateObject(wrappedValue: ReportViewModel(coin: coin))
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            GeometryReader { proxy in
                let containerHeight = baseHeight ?? proxy.size.height
                
                ScrollView {
                    VStack(spacing: 0) {
                        // 헤더
                        HeaderView(
                            heading: coin.koreanName,
                            coinSymbol: coin.coinSymbol,
                            showBackButton: true) {
                                if let onDismiss = onDismiss {
                                    onDismiss()
                                } else {
                                    dismiss()
                                }
                            }
                        
                        VStack(spacing: 16) {
                            tabButtons
                            
                            content(containerHeight: containerHeight)
                        }
                        .padding(.horizontal, 16)
                        .onAppear {
                            if baseHeight == nil { baseHeight = proxy.size.height }
                            guard keyboardObserver == nil else { return }
                            keyboardObserver = NotificationCenter.default.addObserver(
                                forName: UIResponder.keyboardWillChangeFrameNotification,
                                object: nil,
                                queue: .main
                            ) { note in
                                if let end = note.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                                    let h = UIScreen.main.bounds.intersection(end).height
                                    isKeyboardVisible = h > 0
                                }
                            }
                        }
                        .onChange(of: proxy.size.height) { _, newValue in
                            if !isKeyboardVisible {
                                baseHeight = newValue
                            }
                        }
                        .onDisappear {
                            if let token = keyboardObserver {
                                NotificationCenter.default.removeObserver(token)
                                keyboardObserver = nil
                            }
                        }
                    }
                }
                .scrollIndicators(.hidden)
            }
            SafeAreaBackgroundView()
        }
        .onDisappear {
            reportViewModel.cancelAll()
        }
        .toolbar(.hidden, for: .navigationBar)
        .interactiveSwipeBackEnabled()
    }
}

// MARK: - Subviews (Buttons, Content)
extension CoinDetailView {
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

    @ViewBuilder
    fileprivate func content(containerHeight: CGFloat) -> some View {
        if hSizeClass == .regular {
            ChartView(coin: coin)
                .frame(height: containerHeight * Layout.regularChartRatio)
            
            ReportView(viewModel: reportViewModel)
                .padding(.top, 20)
        } else {
            switch selectedTab {
            case .chart:
                ChartView(coin: coin)
                    .frame(height: containerHeight * Layout.compactChartRatio)
            case .report:
                ReportView(viewModel: reportViewModel)
            }
        }
    }
}

// MARK: - Tab
extension CoinDetailView {
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
