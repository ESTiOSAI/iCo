//
//  CoinDetailView.swift
//  AIProject
//
//  Created by 장지현 on 7/31/25.
//

import SwiftUI

struct CoinDetailView: View {
    @State private var selectedTab = 0
    
    let coin: Coin
    
    private let tabs = ["차트", "AI 리포트"]
    
    var body: some View {
        VStack {
            HeaderView(heading: coin.koreanName)
            
            SegmentedControlView(selection: $selectedTab, tabTitles: tabs, width: 150)
            
            // 차트, 보고서 view
            VStack {
                switch selectedTab {
                case 1: ReportView(coin: coin)
                default: ChartView(coin: coin)
                }
            }
            .frame(maxHeight: .infinity)
        }
    }
}

#Preview {
    let sampleCoin = Coin(id: "KRW-BTC", koreanName: "비트코인")
    CoinDetailView(coin: sampleCoin)
}


