//
//  MarketView.swift
//  AIProject
//
//  Created by kangho lee on 7/31/25.
//

import SwiftUI

struct MarketView: View {
    
    @State var store: MarketStore
    @StateObject private var viewModel: SearchViewModel
    
    @State private var searchText: String = ""
    @State private var selectedCoin: Coin?
    
    @FetchRequest(
        fetchRequest: SearchRecordEntity.recent(),
        animation: .default
    )
    private var records: FetchedResults<SearchRecordEntity>
    
    init(coinService: UpBitAPIService, tickerService: RealTimeTickerProvider) {
        store = MarketStore(coinService: coinService, tickerService: tickerService)
        _viewModel = StateObject(wrappedValue: SearchViewModel(upbitService: coinService))
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                HeaderView(heading: "마켓")
                
                SearchBarView(searchText: $searchText)
                    .padding(.horizontal, 16)
                
                if !records.isEmpty {
                    RecentCoinSectionView(
                        coins: records.compactMap { store.coinMeta[$0.query]
                        }) { coin in
                            selectedCoin = coin
                        }
                }
            }
            
            VStack(spacing: 16) {
                HStack(spacing: 16) {
                    RoundedRectangleButton(title: "전체", isActive: store.filter == .none) {
                        store.filter = .none
                    }
                    
                    RoundedRectangleButton(title: "북마크", isActive: store.filter == .bookmark) {
                        store.filter = .bookmark
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                CoinListView(store: store, selectedCoin: $selectedCoin)
            }
            .padding(16)
            .refreshable {
                Task {
                    await store.refresh()
                }
            }
            .onChange(of: searchText, { oldValue, newValue in
                Task {
                   await store.search(newValue)
                }
            })
            .task {
                await store.load()
            }
            .navigationDestination(item: $selectedCoin) { coin in
                CoinDetailView(coin: coin)
            }
        }
    }
}

fileprivate struct RecentCoinSectionView: View {
    let coins: [Coin]
    let action: (Coin) -> Void
    
    var body: some View {
        ScrollView(.horizontal) {
            HStack {
                ForEach(coins) { coin in
                    HStack(spacing: 8) {
                        CoinView(symbol: coin.coinSymbol, size: 20)
                        
                        Text(coin.koreanName)
                            .font(.caption)
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    .background {
                        Capsule().stroke(.defaultGradient, lineWidth: 0.5)
                        
                    }
                    .onTapGesture {
                        action(coin)
                    }
                }
            }
            
        }
        .scrollIndicators(.hidden)
    }
}

#Preview {
    MarketView(
        coinService: UpBitAPIService(),
        tickerService: UpbitTickerService()
    )
}
