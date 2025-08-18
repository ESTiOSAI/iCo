//
//  CoinRowView.swift
//  AIProject
//
//  Created by 백현진 on 8/3/25.
//

import SwiftUI

struct CoinRowView: View {
    let coin: BookmarkEntity
    let imageURL: URL?
    let onDelete: (BookmarkEntity) -> Void

    let size: CGFloat = 30

    var body: some View {
        HStack(spacing: 12) {
            CoinView(symbol: coin.coinSymbol, size: size)

           	HStack(spacing: 8) {
                Text(coin.coinKoreanName)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.primary)

                Text(coin.coinSymbol)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            RoundedButton(imageName: "bookmark.fill") {
                onDelete(coin)
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 16)
    }
}
