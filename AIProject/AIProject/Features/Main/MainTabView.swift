//
//  MainTabView.swift
//  AIProject
//
//  Created by kangho lee on 7/29/25.
//

import SwiftUI

struct MainTabView: View {
    @State private var router = TabRouter()
    @State private var tickerService: RealTimeTickerProvider = UpbitTickerService()
    @State private var upbitService: UpBitAPIService = UpBitAPIService()
    
    var body: some View {
        TabView(selection: $router.selected) {
            ForEach(TabFeature.allCases) { tab in
                makeTab(tab)
                    .tabItem {
                        Label(tab.rawValue, systemImage: tab.icon)
                    }
                    .tag(tab)
            }
        }
        .environment(router)
    }
    
    @ViewBuilder func makeTab(_ tab: TabFeature) -> some View {
        switch tab {
        case .dashboard:
            DashboardView()
        case .market:
            MarketView(
                coinService: upbitService,
                tickerService: tickerService
            )
        case .chatbot:
            ChatBotView()
        case .myPage:
            MyPageView()
        }
    }
}

#Preview {
    MainTabView()
}
