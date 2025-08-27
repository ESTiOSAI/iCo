//
//  CoinDetailView.swift
//  AIProject
//
//  Created by 장지현 on 7/31/25.
//

import SwiftUI

struct CoinDetailView: View {
    @Environment(\.horizontalSizeClass) var hSizeClass
    @State private var selectedTab: Tab = .chart
    @StateObject var reportViewModel: ReportViewModel
    
    let coin: Coin
    
    init(coin: Coin) {
        self.coin = coin
        _reportViewModel = StateObject(wrappedValue: ReportViewModel(coin: coin))
    }
    
    var body: some View {
        GeometryReader { proxy in
            ScrollView {
                VStack(spacing: 0) {
                    // 헤더
                    HeaderView(
                        heading: coin.koreanName,
                        coinSymbol: coin.coinSymbol,
                        showBackButton: true) {
                            // MARK: 콜백?
                        }
                    
                    VStack(spacing: 16) {
                        // 버튼
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
                        
                        // 콘텐츠
                        if hSizeClass == .regular {
                            ChartView(coin: coin)
                                .frame(height: proxy.size.height * 0.55)
                            
                            ReportView(viewModel: reportViewModel)
                                .padding(.top, 20)
                        } else {
                            switch selectedTab {
                            case .chart:
                                ChartView(coin: coin)
                                    .frame(height: proxy.size.height * 0.8)
                            case .report:
                                ReportView(viewModel: reportViewModel)
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                }
            }
            .scrollIndicators(.hidden)
        }
        .onDisappear {
            reportViewModel.cancelAll()
        }
        //        .toolbar(.hidden, for: .navigationBar)
    }
}

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

#Preview {
    let sampleCoin = Coin(id: "KRW-BTC", koreanName: "비트코인")
    CoinDetailView(coin: sampleCoin)
        .environmentObject(ThemeManager())
}
