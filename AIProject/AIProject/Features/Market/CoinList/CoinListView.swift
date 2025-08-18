//
//  CoinListView.swift
//  AIProject
//
//  Created by kangho lee on 7/30/25.
//

import SwiftUI
import AsyncAlgorithms

struct CoinListView: View {
    @Bindable var store: MarketStore
    
    @State private var visibleCoins: Set<CoinID> = []
    @Environment(\.scenePhase) private var scenePhase
    
    @State private var selectedCoin: CoinID?
    
    var body: some View {
        VStack(spacing: 0) {
            List {
                CoinListHeaderView(sortCategory: $store.sortCategory, nameSortOrder: $store.nameSortOrder, volumeSortOrder: $store.volumeSortOrder)
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)

                ForEach(store.sortedCoinIDs, id: \.self) { id in
                    if let meta = store.coinMeta[id], let ticker = store.ticker(for: id) {
                        CoinCell(coin: meta, store: ticker)
                            .onTapGesture {
                                selectedCoin = id
                            }
                            .onAppear {
                                visibleCoins.insert(id)
                            }
                            .onDisappear {
                                visibleCoins.remove(id)
                            }
                    }
                }
                .listRowBackground(Color.clear)
            }
            .listStyle(.plain)
            .coordinateSpace(name: "scroll")
            .scrollContentBackground(.hidden)
            .background {
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.aiCoBorderGray, lineWidth: 1)
                    .fill(Color.aiCoBackground)
            }
        }
        .onChange(of: scenePhase, { _, newValue in
            Task {
                await handleConnection(by: newValue)
            }
        })
        .onChange(of: visibleCoins, { oldValue, newValue in
            Task {
                await store.sendTicket(newValue)
            }
        })
        .onAppear {
            Task {
                await store.connect()
            }
        }
        .onDisappear {
            Task {
                await store.disconnect()
            }
        }
        .navigationDestination(item: $selectedCoin) { coinID in
            if let coin = store.coinMeta[coinID] {
                CoinDetailView(coin: coin)
            }
        }
    }
}

extension CoinListView {
    private func handleConnection(by phase: ScenePhase) async {
        print(#function, phase)
        switch phase {
        case .background:
            await store.disconnect()
        case .inactive:
            break
        case .active:
            await store.connect()
        @unknown default:
            break
        }
    }
}
