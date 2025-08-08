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
    @State var viewModel: MarketViewModel = MarketViewModel(upbitService: .init(), coinListViewModel: CoinListViewModel(socket: .init()))
    
    var body: some View {
        NavigationStack {
            VStack {
                HeaderView(heading: "마켓", showSearchButton: true) {
                    isShowSearchView = true
                }
                
                VStack(spacing: 8) {
                                    
                SegmentedControlView(selection: $selectedTabIndex,
                                     tabTitles: ["북마크한 코인", "전체 코인"],
                                     width: 200)
                .frame(height: 44)
                
                    CoinListView(viewModel: viewModel.coinListViewModel)
                }
                .refreshable {
                    Task {
                        await viewModel.refresh()
                        viewModel.change(tab: MarketCoinTab(rawValue: selectedTabIndex) ?? .bookmark)
                    }
                }
            }
            .onChange(of: selectedTabIndex, { _, newValue in
                if let tab = MarketCoinTab(rawValue: newValue) {
                    viewModel.change(tab: tab)
                }
            })
            .navigationDestination(isPresented: $isShowSearchView) {
                SearchView()
            }
        }
    }
}

#Preview {
    MarketView()
}
