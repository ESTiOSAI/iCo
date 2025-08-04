//
//  CoinListSectionView.swift
//  AIProject
//
//  Created by 백현진 on 8/4/25.
//

import SwiftUI

struct CoinListSectionView: View {
    let sortedCoins: [CoinListModel]
    @Binding var selectedCategory: SortCategory?
    @Binding var nameOrder: SortOrder
    @Binding var priceOrder: SortOrder
    @Binding var volumeOrder: SortOrder

    var body: some View {
        LazyVStack(spacing: 8) {
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

                SortToggleButton(
                    title: "현재가/변동",
                    sortCategory: .price,
                    currentCategory: $selectedCategory,
                    sortOrder: $priceOrder
                )
                .frame(width: 100, alignment: .trailing)
                .onChange(of: selectedCategory) { _, newKey in
                    if newKey != .price { priceOrder = .none }
                }

                SortToggleButton(
                    title: "거래대금",
                    sortCategory: .volume,
                    currentCategory: $selectedCategory,
                    sortOrder: $volumeOrder
                )
                .frame(width: 100, alignment: .trailing)
                .onChange(of: selectedCategory) { _, newKey in
                    if newKey != .volume { volumeOrder = .none }
                }
            }
            .padding(.horizontal, 16)
            .fontWeight(.regular)
            .font(.system(size: 12))
            .foregroundStyle(.aiCoLabel)

            Divider()

            ForEach(sortedCoins) { coin in
                NavigationLink {
                    MockDetailView(coin: coin)
                } label: {
                    CoinRowView(coin: coin)
                }
            }
        }
    }
}
