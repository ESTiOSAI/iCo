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
    @State private var selectedCoinID: CoinID?
    @State private var columnVisibility: NavigationSplitViewVisibility = .all

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
        NavigationSplitView(columnVisibility: $columnVisibility, preferredCompactColumn: .constant(.sidebar)) {
            Group {
                VStack(spacing: 16) {
                    HeaderView(heading: "마켓")

                    SearchBarView(searchText: $searchText)
                        .padding(.horizontal, 16)

                    if !records.isEmpty {
                        RecentCoinSectionView(coins: records.compactMap { store.coinMeta[$0.query] }, deleteAction: { coin in
                            store.deleteRecord(coin.id)
                        }) { selectedCoinID = $0 }
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

                    CoinListView(store: store, selectedCoinID: $selectedCoinID)
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
            }
            .toolbar(removing: .sidebarToggle)
            .navigationSplitViewColumnWidth(min: 330, ideal: 350, max: 400)
            
        } detail: {
            if let selectedCoinID, let coin = store.coinMeta[selectedCoinID] {
                CoinDetailView(coin: coin)
                    .id(coin.id)
                
            } else {
                Text("Empty")
            }
        }
        .navigationSplitViewStyle(.balanced)
        
    }
}

#Preview {
    MarketView(
        coinService: UpBitAPIService(),
        tickerService: UpbitTickerService()
    )
}
