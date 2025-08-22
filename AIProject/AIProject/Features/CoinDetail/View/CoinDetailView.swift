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
    
    let coin: Coin
    
    var body: some View {
        GeometryReader { proxy in
            ScrollView {
                VStack(spacing: 12) {
                    HStack(alignment: .firstTextBaseline, spacing: 8) {
                        if hSizeClass == .regular {
                            // FIXME: HeaderView로 교체 필요
                            Text(coin.koreanName)
                                .font(.system(size: 24, weight: .black))
                                .foregroundStyle(.aiCoLabel)
                        } else {
                            Text(coin.koreanName)
                                .font(.system(size: 18, weight: .bold))
                                .foregroundStyle(.aiCoLabel)
                        }
                        
                        Text(coin.coinSymbol)
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(.aiCoLabelSecondary)
                        
                        Spacer()
                    }
                    .padding(.bottom, 5)
                    .padding(.horizontal, 16)
                    
                    if hSizeClass == .compact {
                        HStack(spacing: 8) {
                            ForEach(Tab.allCases) { tab in
                                RoundedRectangleButton(
                                    title: tab.title,
                                    isActive: selectedTab == tab
                                ) {
                                    withAnimation(.easeInOut(duration: 0.22)) {
                                        selectedTab = tab
                                    }
                                }
                                .frame(height: 36)
                            }
                            Spacer(minLength: 0)
                        }
                        .padding(.bottom, 10)
                        .padding(.horizontal, 16)
                    }
                    
                    if hSizeClass == .regular {
                        ChartView(coin: coin)
                            .frame(height: proxy.size.height * 0.55)
                        
                        ReportView(coin: coin)
                            .padding(.top, 20)
                    } else {
                        switch selectedTab {
                        case .chart:
                            ChartView(coin: coin)
                                .frame(height: proxy.size.height * 0.8)
                        case .report:
                            ReportView(coin: coin)
                        }
                    }
                }
                .padding(.top, 20)
            }
        }
    }
}

extension CoinDetailView {
    private enum Tab: Int, CaseIterable, Identifiable {
        case chart
        case report

        var id: Int { rawValue }

        var title: String {
            switch self {
            case .chart: return "차트"
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
