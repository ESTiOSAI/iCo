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
            VStack(spacing: 0) {
                HeaderView(heading: "마켓")
                
                SearchBarView(searchText: $searchText)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 20)
                
                if !records.isEmpty {
                    RecentCoinSectionView(coins: records.compactMap { store.coinMeta[$0.query] }, deleteAction: { coin in
                        store.deleteRecord(coin.id)
                    }) { selectedCoinID = $0 }
                        .padding(.bottom, 16)
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
                    .padding(.bottom, 4)

                    CoinListView(store: store, selectedCoinID: $selectedCoinID, searchText: $searchText)
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
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
                
            }
        }
        .navigationSplitViewStyle(.balanced)
        
    }
}

#Preview {
    MarketView(
        coinService: UpBitAPIService(),
        tickerService: UpbitTickerService(client:
                                          ReconnectableWebSocketClient {
                                          BaseWebSocketClient(url: URL(string: "wss://api.upbit.com/websocket/v1")!)
                                          })
    )
}
