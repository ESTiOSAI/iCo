//
//  MarketView.swift
//  AIProject
//
//  Created by kangho lee on 7/31/25.
//

import SwiftUI

struct MarketView: View {
    @State var isShowSearchView = false
    @State var selectedTab = MarketCoinTab.total
    @State var viewModel: MarketViewModel = MarketViewModel(upbitService:  .init(), coinListViewModel: CoinListViewModel(tickerService: UpbitTickerService(client: .init(pingInterval: .seconds(120))), coinGeckoService: CoinGeckoAPIService()))
    @State var bookmarkSelected = true
    @State var totalSelected = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                HeaderView(heading: "마켓", showSearchButton: true, onSearchTap: {
                    isShowSearchView = true
                })
                
                VStack(spacing: 8) {
                    HStack(spacing: 16) {
                        RoundedRectangleButton(title: "전체코인", isActive: selectedTab == .total) {
                            selectedTab = .total
                            viewModel.change(tab: .total)
                        }
                        
                        RoundedRectangleButton(title: "북마크", isActive: selectedTab == .bookmark) {
                            selectedTab = .bookmark
                            viewModel.change(tab: .bookmark)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(16)
                
                    CoinListView(viewModel: viewModel.coinListViewModel)
                        .padding(.horizontal, 16)
                }
                .refreshable {
                    Task {
                        await viewModel.refresh()
                    }
                }
            }
            .navigationDestination(isPresented: $isShowSearchView) {
                SearchView()
            }
        }
    }
}

#Preview {
    MarketView()
}
