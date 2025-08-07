//
//  CoinListSectionView.swift
//  AIProject
//
//  Created by 백현진 on 8/4/25.
//

import SwiftUI

struct CoinListSectionView: View {
    let sortedCoins: [BookmarkEntity]
    @Binding var selectedCategory: SortCategory?
    @Binding var nameOrder: SortOrder
    @Binding var priceOrder: SortOrder
    @Binding var volumeOrder: SortOrder

    var body: some View {
        List {
            HStack {
                SortToggleButton(
                    title: "코인명",
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
                NavigationLink {
                    CoinDetailView(coin: Coin(id: coin.coinID, koreanName: coin.coinID))
                } label: {
                    CoinRowView(coin: coin)
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
        }
    }
}
