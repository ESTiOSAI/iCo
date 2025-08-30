//
//  CoinListSectionView.swift
//  AIProject
//
//  Created by 백현진 on 8/4/25.
//

import SwiftUI

struct CoinListSectionView: View {
    let sortedCoins: [BookmarkEntity]
    @Environment(CoinStore.self) var coinStore
    
    @Binding var selectedCategory: SortCategory?
    @Binding var nameOrder: SortOrder
    @Binding var priceOrder: SortOrder
    @Binding var volumeOrder: SortOrder

    let imageProvider: (String) -> UIImage?
    let onDelete: (BookmarkEntity) -> Void

    var body: some View {
        VStack {
            HStack {
                SortToggleButton(
                    title: "한글명",
                    sortCategory: .name,
                    currentCategory: $selectedCategory,
                    sortOrder: $nameOrder
                )
                .frame(maxWidth: .infinity, alignment: .leading)
                .onChange(of: selectedCategory) { _, newKey in
                    if newKey != .name { nameOrder = .none }
                }
            }
            .padding(.horizontal, 16)
            .fontWeight(.regular)
            .font(.system(size: 12))
            .foregroundStyle(.aiCoLabel)

            ForEach(sortedCoins, id: \.coinID) { coin in
                if let meta = coinStore.coins[coin.coinID] {
                    NavigationLink {
                        VStack(spacing: 0) {
                            HeaderView(
                                heading: meta.koreanName,
                                coinSymbol: meta.coinSymbol,
                                showBackButton: true
                            )
                            .toolbar(.hidden, for: .navigationBar)
                            
                            CoinDetailView(coin: meta)
                                .id(coin.id)
                        }
                    } label: {
                        CoinRowView(coin: coin, prefetched: imageProvider(coin.coinSymbol), onDelete: onDelete)
                    }
                }
            }
        }
        .padding(.top, 16)
        .padding(.bottom, 16)
        .background(.aiCoBackground.opacity(0.7))
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.aiCoBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(.defaultGradient, lineWidth: 0.5)
                )
        )
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
