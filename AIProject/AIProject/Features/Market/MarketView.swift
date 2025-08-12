//
//  MarketView.swift
//  AIProject
//
//  Created by kangho lee on 7/31/25.
//

import SwiftUI

struct MarketView: View {
    @State var isShowSearchView = false
    @State var selectedTabIndex: Int = 0
    @State var viewModel: MarketViewModel = MarketViewModel(upbitService:  .init(), coinListViewModel: CoinListViewModel(tickerService: UpbitTickerService(client: .init(pingInterval: .seconds(120)))))
    @State var bookmarkSelected = true
    @State var totalSelected = false
    
    var body: some View {
        NavigationStack {
            VStack {
                HeaderView(heading: "마켓", showSearchButton: true, onSearchTap: {
                    isShowSearchView = true
                })
                
                VStack(spacing: 8) {
                    HStack {
                        RoundedRectangleFillButton(title: "전체 코인", isHighlighted: $totalSelected) {
                            viewModel.change(tab: .total)
                        }
                        .frame(width: 100, height: 44)
                        
                        RoundedRectangleFillButton(title: "북마크", isHighlighted: $bookmarkSelected) {
                            viewModel.change(tab: .bookmark)
                        }
                        .frame(width: 100, height: 44)
                        
                        Spacer()
                    }
                    .padding(16)
                
                    CoinListView(viewModel: viewModel.coinListViewModel)
                }
                .refreshable {
                    Task {
                        await viewModel.refresh()
                        viewModel.change(tab: MarketCoinTab(rawValue: selectedTabIndex) ?? .bookmark)
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
