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
    @State private var isActive: Bool = false
    
    @Environment(\.scenePhase) private var scenePhase
    @Environment(TabRouter.self) private var router
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \BookmarkEntity.timestamp, ascending: false)],
        animation: .default
    )
    private var bookmarks: FetchedResults<BookmarkEntity>
    
    @Binding private var selectedCoinID: CoinID?
    @Binding private var searchText: String
    
    init(store: MarketStore, selectedCoinID: Binding<CoinID?>, searchText: Binding<String>) {
        self.store = store
        _selectedCoinID = selectedCoinID
        _searchText = searchText
    }
    
    var body: some View {
        VStack(spacing: 0) {
            CoinListHeaderView(sortCategory: $store.sortCategory, rateSortOrder: $store.rateSortOrder, volumeSortOrder: $store.volumeSortOrder)
            makeCoinContents()
        }
        .overlay {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(.defaultGradient, lineWidth: 0.5)
        }
        .background {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.aiCoBackground)
        }
        .clipShape(.rect(cornerRadius: 16))
        .onChange(of: scenePhase, { _, newValue in
            Task {
                guard router.selected == .market && isActive else { return }
                await handleConnection(by: newValue)
            }
        })
        .onChange(of: visibleCoins, { oldValue, newValue in
            Task {
                await store.sendTicket(newValue)
            }
        })
        .onChange(of: bookmarks.map(\.coinID), initial: true) { oldValue, newValue in
            Task {
                await store.update(newValue)
            }
        }
        .task {
            isActive = true
            guard router.selected == .market else { return }
            await store.connect()
        }
        .onDisappear {
            Task {
                isActive = false
                await store.disconnect()
            }
        }
    }
    
    @ViewBuilder func makeCoinContents() -> some View {
        if store.filter == .bookmark, bookmarks.isEmpty {
            VStack {
                Text("북마크한 코인이 없습니다 🥵")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, minHeight: 300)
                    .multilineTextAlignment(.center)
                    .padding()
            }
            .frame(maxHeight: .infinity)
        } else {
            List(store.sortedCoinIDs, id: \.self, selection: $selectedCoinID) { id in
                if let meta = store.coinMeta[id], let ticker = store.ticker(for: id) {
                    CoinCell(coin: meta, store: ticker, searchTerm: searchText)
                        .listRowSeparator(.hidden)
                        .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                        .listRowBackground(selectedCoinID == id && isIpad ? Color.aiCoBackgroundAccent : Color.clear)
                        .overlay(
                            LinearGradient.defaultGradient.frame(height: 0.5),
                            alignment: .bottom
                        )
                        .onTapGesture {
                            store.addRecord(id)
                            selectedCoinID = id
                        }
                        .onAppear {
                            visibleCoins.insert(id)
                        }
                        .onDisappear {
                            visibleCoins.remove(id)
                        }
                }
            }
            .listStyle(.plain)
            .scrollIndicators(.hidden)
            .scrollContentBackground(.hidden)
        }
    }
}

extension CoinListView {
    private var isIpad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
    
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
