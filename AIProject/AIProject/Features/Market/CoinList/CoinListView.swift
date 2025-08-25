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
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \BookmarkEntity.timestamp, ascending: false)],
        animation: .default
    )
    private var bookmarks: FetchedResults<BookmarkEntity>
    
    @Binding private var selectedCoinID: CoinID?
    
    init(store: MarketStore, selectedCoinID: Binding<CoinID?>) {
        self.store = store
        _selectedCoinID = selectedCoinID
    }
    
    var body: some View {
        VStack(spacing: 0) {
            CoinListHeaderView(sortCategory: $store.sortCategory, rateSortOrder: $store.rateSortOrder, volumeSortOrder: $store.volumeSortOrder)
            makeCoinContents()
        }
        .background {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(.defaultGradient, lineWidth: 0.5)
                .fill(Color.aiCoBackground)
        }
        .clipShape(.rect(cornerRadius: 16))
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
        .onChange(of: bookmarks.map(\.coinID), initial: true) { oldValue, newValue in
            Task {
                await store.update(newValue)
            }
        }
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
    }
    
    @ViewBuilder func makeCoinContents() -> some View {
        if store.filter == .bookmark, bookmarks.isEmpty {
            VStack {
                Spacer()
                
                Text("북마크한 코인이 없습니다 🥵")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, minHeight: 300)
                    .multilineTextAlignment(.center)
                    .padding()
                
                Spacer()
            }
        } else {
            List(store.sortedCoinIDs, id: \.self, selection: $selectedCoinID) { id in
                if let meta = store.coinMeta[id], let ticker = store.ticker(for: id) {
                    CoinCell(coin: meta, store: ticker)
                        .listRowSeparator(.hidden)
                        .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                        .listRowBackground(selectedCoinID == id && isIpad ? Color.aiCoNeutral : Color.clear)
                        .background(Rectangle().stroke(.defaultGradient, lineWidth: 0.5))
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
