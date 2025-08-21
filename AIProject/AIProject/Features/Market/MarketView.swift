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
        NavigationSplitView(columnVisibility: $columnVisibility) {
            Group {
                VStack(spacing: 16) {
                    HeaderView(heading: "마켓")

                    SearchBarView(searchText: $searchText)
                        .padding(.horizontal, 16)

                    if !records.isEmpty {
                        RecentCoinSectionView(coins: records.compactMap { store.coinMeta[$0.query] }, deleteAction: { coin in
                            // TODO: 삭제 작업 필요
                        }) { coin in selectedCoin = coin }
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
            .navigationSplitViewColumnWidth(min: 400, ideal: 400, max: 400)
        } detail: {
            if let selectedCoin {
                CoinDetailView(coin: selectedCoin)
            } else {
                Text("Empty")
            }
        }
        .navigationSplitViewStyle(.balanced) // 균등 분할
    }
}

fileprivate struct RecentCoinSectionView: View {
    let coins: [Coin]
    let deleteAction: (Coin) -> Void
    let tapAction: (Coin) -> Void

    var body: some View {
        ScrollView(.horizontal) {
            HStack {
                ForEach(coins) { coin in
                    HStack(spacing: 8) {
                        Text(coin.koreanName)
                            .font(.system(size: 14))

                        Button {
                            deleteAction(coin)
                        } label: {
                            Image(systemName: "xmark")
                                .resizable()
                                .frame(width: 10, height: 10)
                                .foregroundStyle(.aiCoLabelSecondary)
                        }
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    .background {
                        Capsule().stroke(.defaultGradient, lineWidth: 0.5)
                    }
                    .onTapGesture {
                        tapAction(coin)
                    }
                }
            }
        }
        .safeAreaPadding(.horizontal, 16)
        .scrollIndicators(.hidden)
    }
}

#Preview {
    MarketView(
        coinService: UpBitAPIService(),
        tickerService: UpbitTickerService()
    )
}
