//
//  CoinDetailView.swift
//  AIProject
//
//  Created by 장지현 on 7/31/25.
//

import SwiftUI

struct CoinDetailView: View {
    @State private var selectedTab = 0
    let tabs = ["차트", "보고서"]
    let coin: Coin
    
    var body: some View {
        VStack {
            HeaderView(heading: coin.koreanName)
            
            SegmentedControlView(selection: $selectedTab, tabTitles: tabs, width: 120)
            
            // 차트, 보고서 view
            VStack {
                Group {
                    switch selectedTab {
                    case 0: /*ChartView()*/ Text("차트") // 차트뷰 호출
                    case 1: /*ReportView()*/ Text("보고서") // 보고서뷰 호출
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


