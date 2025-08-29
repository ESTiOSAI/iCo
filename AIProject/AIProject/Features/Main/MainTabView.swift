//
//  MainTabView.swift
//  AIProject
//
//  Created by kangho lee on 7/29/25.
//

import SwiftUI

struct MainTabView: View {
    @State private var router = TabRouter()
    private let tickerService: RealTimeTickerProvider
    private let coinService: UpBitAPIService
    
    init(
        tickerService: RealTimeTickerProvider,
        coinService: UpBitAPIService
    ) {
        self.tickerService = tickerService
        self.coinService = coinService
    }
    
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
                coinService: coinService,
                tickerService: tickerService
            )
        case .chatbot:
            ChatBotView()
        case .myPage:
            MyPageView()
                .transaction { $0.animation = nil }
        }
    }
}

#Preview {
    MainTabView(
        tickerService: UpbitTickerService(),
        coinService: UpBitAPIService()
    )
}
