//
//  RecentCoinSectionView.swift
//  AIProject
//
//  Created by kangho lee on 8/26/25.
//

import SwiftUI

struct RecentCoinSectionView: View {
    let coins: [Coin]
    let deleteAction: (Coin) -> Void
    let tapAction: (CoinID) -> Void

    var body: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 8) {
                ForEach(coins) { coin in
                    HStack(spacing: 8) {
                        Text(coin.koreanName)
                            .font(.ico14)

                        Button {
                            deleteAction(coin)
                        } label: {
                            Image(systemName: "xmark")
                                .resizable()
                                .frame(width: 10, height: 10)
                                .foregroundStyle(.iCoLabelSecondary)
                        }
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    .background {
                        Capsule().strokeBorder(.defaultGradient, lineWidth: 0.5)
                    }
                    .onTapGesture {
                        tapAction(coin.id)
                    }
                }
            }
        }
        .safeAreaPadding(.horizontal, 16)
        .scrollIndicators(.hidden)
    }
}
