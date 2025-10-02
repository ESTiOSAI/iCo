//
//  MarketView.swift
//  AIProject
//
//  Created by kangho lee on 7/31/25.
//

import SwiftUI

struct MarketView: View {
    
    @State var store: MarketStore
    
    @State private var searchText: String = ""
    @State private var selectedCoinID: CoinID?
    @State private var columnVisibility: NavigationSplitViewVisibility = .all
    @Environment(\.horizontalSizeClass) var hSizeClass
    
    @FetchRequest(
        fetchRequest: SearchRecordEntity.recent(),
        animation: .default
    )
    private var records: FetchedResults<SearchRecordEntity>
    
    init(coinService: UpBitAPIService, tickerService: RealTimeTickerProvider) {
        store = MarketStore(coinService: coinService, tickerService: tickerService)
    }
    
    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility, preferredCompactColumn: .constant(.sidebar)) {
            VStack(spacing: 0) {
                makeHeader()
                    .dissmissKeyboardOnTap()
                
                CoinListView(store: store, selectedCoinID: $selectedCoinID, searchText: $searchText)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)
                
                    .refreshable {
                        Task {
                            await store.refresh()
                        }
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
            .toolbar(removing: .sidebarToggle)
            .toolbar(.hidden, for: .navigationBar)
            .navigationSplitViewColumnWidth(min: 340, ideal: 340, max: 350)
            
        } detail: {
            if let selectedCoinID, let coin = store.coinMeta[selectedCoinID] {
                NavigationStack {
                    VStack(spacing: 0) {
                        HeaderView(
                            heading: coin.koreanName,
                            coinSymbol: coin.coinSymbol,
                            showBackButton: hSizeClass == .regular ? false : true
                        )
                        .toolbar(.hidden, for: .navigationBar)
                        
                        CoinDetailView(coin: coin)
                            .id(coin.id)
                    }
                }
            } else {
                CommonPlaceholderView(imageName: "logo", text: "조회할 코인을 선택하세요")
                    .toolbar(.hidden, for: .navigationBar)
            }
        }
        .navigationSplitViewStyle(.balanced)
    }
}

extension MarketView {
    @ViewBuilder func makeHeader() -> some View {
        VStack(spacing: 0) {
            HeaderView(heading: "마켓")
            
            SearchBarView(searchText: $searchText)
                .padding(.horizontal, 16)
            
            VStack(spacing: 0) {
                if !records.isEmpty {
                    RecentCoinSectionView(coins: records.compactMap { store.coinMeta[$0.query] }, deleteAction: { coin in
                        store.deleteRecord(coin.id)
                    }) { selectedCoinID = $0 }
                        .padding(.bottom, 16)
                }
                
                HStack(spacing: 16) {
                    RoundedRectangleButton(title: "전체", isActive: store.filter == .none) {
                        store.filter = .none
                    }
                    
                    RoundedRectangleButton(title: "북마크", isActive: store.filter == .bookmark) {
                        store.filter = .bookmark
                    }
                    
                    Spacer()
                }
                .frame(alignment: .leading)
                .padding(.horizontal, 16)
            }
            .padding(.vertical, 20)
        }
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
