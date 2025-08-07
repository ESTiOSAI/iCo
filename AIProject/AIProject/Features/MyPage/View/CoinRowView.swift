//
//  CoinRowView.swift
//  AIProject
//
//  Created by 백현진 on 8/3/25.
//

import SwiftUI

struct CoinRowView: View {
    let coin: BookmarkEntity

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "bitcoinsign.circle.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 28, height: 28)
                .padding(4)
                .background(Color.orange)
                .clipShape(RoundedRectangle(cornerRadius: 6))
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(Color.purple, lineWidth: 2)
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
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 16)
    }
}
