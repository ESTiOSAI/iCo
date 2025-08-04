//
//  CoinDetailView.swift
//  AIProject
//
//  Created by 장지현 on 7/31/25.
//

import SwiftUI

struct CoinDetailView: View {
    @State private var selectedTab = 0
    private let tabs = ["차트", "AI 리포트"]
    let coin: Coin
    
    var body: some View {
        VStack {
            HeaderView(heading: coin.koreanName)
            
            SegmentedControlView(selection: $selectedTab, tabTitles: tabs, width: 150)
            
            // 차트, 보고서 view
            VStack {
                Group {
                    switch selectedTab {
                    case 0: /*ChartView()*/ Text("차트") // 차트뷰 호출
                    case 1: ReportView(coin: coin)
                    default: /*ChartView()*/ Text("차트")
                    }
                }
            }
            .frame(maxHeight: .infinity)
        }
    }
}

#Preview {
    CoinDetailView(coin: Coin(id: "KRW-BTC", koreanName: "비트코인"))
}


