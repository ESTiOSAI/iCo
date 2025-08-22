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
                VStack(spacing: 0) {
                    // 헤더
                    if hSizeClass == .regular {
                        HStack(alignment: .lastTextBaseline) {
                            HeaderView(heading: coin.koreanName) // FIXME: 코인 심볼
                        }
                    } else {
                        HStack(alignment: .firstTextBaseline, spacing: 8) {
                            Text(coin.koreanName)
                                .font(.system(size: 18, weight: .bold))
                                .foregroundStyle(.aiCoLabel)
                            
                            Text(coin.coinSymbol)
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundStyle(.aiCoLabelSecondary)
                            
                            Spacer()
                        }
                        .padding(EdgeInsets(top: 20, leading: 16, bottom: 16, trailing: 16))
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
                    .padding(.horizontal, 16)
                }
            }
            .scrollIndicators(.hidden)
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
