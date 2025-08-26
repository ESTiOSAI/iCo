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

    let imageURLProvider: (String) -> URL?
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
                NavigationLink {
                    CoinDetailView(coin: Coin(id: coin.coinID, koreanName: coin.coinID))
                } label: {
                    CoinRowView(coin: coin, imageURL: imageURLProvider(coin.coinSymbol), onDelete: onDelete)
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
