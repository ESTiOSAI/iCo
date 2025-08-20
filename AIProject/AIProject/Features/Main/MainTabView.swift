//
//  MainTabView.swift
//  AIProject
//
//  Created by kangho lee on 7/29/25.
//

import SwiftUI

struct MainTabView: View {
    
    var body: some View {
        TabView {
            DashboardView()
                .tabItem {
                    Label("대시보드", systemImage: "square.grid.2x2")
                }
            
            MarketView(
                coinService: UpBitAPIService(),
                tickerService: UpbitTickerService()
            )
                .tabItem {
                    Label("마켓", systemImage: "bitcoinsign.bank.building")
                }
            
            ChatBotView()
                .tabItem {
                    Label("챗봇", systemImage: "bubble.left.and.text.bubble.right")
                }
            
            MyPageView()
                .tabItem {
                    Label("마이페이지", systemImage: "person.crop.circle")
                }
        }
    }
}

#Preview {
    MainTabView()
}
