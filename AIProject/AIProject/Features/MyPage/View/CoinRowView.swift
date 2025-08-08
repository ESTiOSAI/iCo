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

    var body: some View {
        HStack(spacing: 12) {
            Group {
                if let url = imageURL {
                    AsyncImage(url: url) { img in
                        img.resizable()
                            .aspectRatio(contentMode: .fit)
                    } placeholder: {
                        ProgressView()
                    }
                } else {
                    Text(String(coin.coinSymbol.prefix(1)))
                        .font(.caption.bold())
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .frame(width: 28, height: 28)
            .padding(4)
            .background(Color.orange)
            .clipShape(Circle())

            VStack(alignment: .leading, spacing: 2) {
                Text(coin.coinKoreanName)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.primary)

                Text(coin.coinID)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 16)
    }
}
