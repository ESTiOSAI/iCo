//
//  MarketView.swift
//  AIProject
//
//  Created by kangho lee on 7/31/25.
//

import SwiftUI

struct MarketView: View {
    @State var viewModel: MarketViewModel
    @State var coinStore: CoinListStore

    @State var isShowSearchView = false
    @State var selectedTab = MarketCoinTab.total
    @State var bookmarkSelected = true
    @State var totalSelected = false
    @State var collapse = false
    
    init(upbitService: UpBitAPIService, tickerService: UpbitTickerService) {
        viewModel = MarketViewModel(upbitService: upbitService)
        coinStore = CoinListStore(tickerService: tickerService)
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                VStack(spacing: 16) {
                    HeaderView(heading: "마켓", showSearchButton: true, onSearchTap: {
                        isShowSearchView = true
                    })
                    
                    HStack(spacing: 16) {
                        RoundedRectangleButton(title: "전체코인", isActive: selectedTab == .total) {
                            changeTab(.total)
                        }
                        
                        RoundedRectangleButton(title: "북마크", isActive: selectedTab == .bookmark) {
                            changeTab(.bookmark)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 16)
                
                    CoinListView(store: coinStore)
                        .padding(.horizontal, 16)
                        .padding(.bottom, 16)
                }
                .refreshable {
                    Task {
                        await viewModel.refresh()
                    }
                }
            }
            .task {
                coinStore.change(viewModel.totalCoins)
            }
            .navigationDestination(isPresented: $isShowSearchView) {
                SearchView()
            }
        }
    }
}

extension MarketView {
    func changeTab(_ tab: MarketCoinTab) {
        selectedTab = tab
        switch tab {
        case .bookmark:
            coinStore.change(viewModel.bookmaredCoins)
        case .total:
            coinStore.change(viewModel.totalCoins)
        }
    }
}

#Preview {
    MarketView(upbitService: UpBitAPIService(), tickerService: UpbitTickerService())
}
