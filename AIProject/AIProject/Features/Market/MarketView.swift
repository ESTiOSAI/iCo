//
//  MarketView.swift
//  AIProject
//
//  Created by kangho lee on 7/31/25.
//

import SwiftUI

struct MarketView: View {
    @State var store: MarketStore

    @State private var isShowSearchView = false
    @State private var bookmarkSelected = true
    @State private var totalSelected = false
    @State private var collapse = false
    
    init(coinService: UpBitAPIService, tickerService: UpbitTickerService) {
        store = MarketStore(coinService: coinService, tickerService: tickerService)
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                VStack(spacing: 16) {
                    HeaderView(heading: "마켓", showSearchButton: true, onSearchTap: {
                        isShowSearchView = true
                    })
                    
                    HStack(spacing: 16) {
                        RoundedRectangleButton(title: "전체코인", isActive: store.filter == .none) {
                            store.filter = .none
                        }
                        
                        RoundedRectangleButton(title: "북마크", isActive: store.filter == .bookmark) {
                            store.filter = .bookmark
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 16)
                
                    CoinListView(store: store)
                        .padding(.horizontal, 16)
                        .padding(.bottom, 16)
                }
                .refreshable {
                    Task {
                        await store.refresh()
                    }
                }
            }
            .onChange(of: store.filter, { oldValue, newValue in
                store.sort()
            })
            .task {
                await store.load()
            }
            .navigationDestination(isPresented: $isShowSearchView) {
                SearchView()
            }
        }
    }
}

#Preview {
    MarketView(
        coinService: UpBitAPIService(),
        tickerService: UpbitTickerService()
    )
}
