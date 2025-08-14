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
    @State var collapse = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                VStack(spacing: 16) {
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
                    .padding(.horizontal, 16)
                
                    CoinListView(viewModel: viewModel.coinListViewModel)
                        .padding(.horizontal, 16)
                        .padding(.bottom, 16)
                }
                .refreshable {
                    Task {
                        await viewModel.refresh()
                    }
                }
            }
            .safeAreaInset(edge: .top) {
                VStack(spacing: 10) {
                    HeaderView(heading: "마켓", showSearchButton: true, onSearchTap: {
                        isShowSearchView = true
                    })
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 12)
                .background(.ultraThinMaterial)
                // 접기 애니메이션(높이/불투명도)
                .opacity(collapse ? 0 : 1)
                .frame(height: collapse ? 0 : nil, alignment: .top)
                .clipped()
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
