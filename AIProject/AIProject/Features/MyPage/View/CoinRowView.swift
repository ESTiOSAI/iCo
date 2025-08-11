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
            Group {
                if let url = imageURL {
                    AsyncImage(url: url) { img in
                        img.resizable().aspectRatio(contentMode: .fit)
                    } placeholder: { ProgressView() }
                } else {
                    Text(String(coin.coinSymbol.prefix(1)))
                        .font(.caption.bold())
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .frame(width: size, height: size)
            .clipShape(Circle())
            .contentShape(Circle())
            .overlay(
                Circle().strokeBorder(Color.secondary.opacity(0.25), lineWidth: 1)
            )

            VStack(alignment: .leading, spacing: 2) {
                Text(coin.coinKoreanName)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.primary)

                Text(coin.coinID)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Button {
                onDelete(coin)
                print("북마크 삭제 삭제삭제")
            } label: {
                Image(systemName: "bookmark.fill")
                    .resizable()
                    .frame(width: size / 3, height: size / 2)
                    .foregroundColor(.red)
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 16)
    }
}
