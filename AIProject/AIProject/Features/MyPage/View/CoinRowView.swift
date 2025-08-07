//
//  CoinRowView.swift
//  AIProject
//
//  Created by 백현진 on 8/3/25.
//

import SwiftUI

//struct CoinRowView: View {
//    let coin: CoinListModel
//
//    var body: some View {
//        HStack(alignment: .top, spacing: 0) {
//            HStack(spacing: 8) {
//                Image(systemName: "bitcoinsign.circle.fill")
//                    .resizable()
//                    .frame(width: 30, height: 30)
//                    .background(Circle().fill(.yellow))
//                    .clipShape(Circle())
//
//                VStack(alignment: .leading, spacing: 2) {
//                    Text(coin.name)
//                        .font(.system(size: 15))
//                        .foregroundColor(.aiCoLabel)
//
//                    Text(coin.coinID)
//                        .font(.caption)
//                        .foregroundColor(.aiCoLabelSecondary)
//                }
//
//            }
//            .frame(maxWidth: .infinity, alignment: .leading)
//
//            // 가격
//            VStack(alignment: .trailing, spacing: 2) {
//                HStack(spacing: 2) {
//                    Text(coin.currentPrice, format: .number)
//                    Text("원")
//                }
//                .foregroundColor(Color.aiCoLabel)
//                .font(.system(size: 12))
//
//                HStack(spacing: 2) {
//                    Text(coin.changePrice, format: .number)
//                    Text("%")
//                }
//                .font(.caption)
//                .foregroundColor(Color.aiCoPositive)
//            }
//            .frame(width: 100, alignment: .trailing)
//
//            // 거래 대금
//            VStack(alignment: .trailing, spacing: 2) {
//                HStack(spacing: 2) {
//                    Text(coin.tradeAmount.formatMillion)
//                }
//                .font(.system(size: 15))
//                .foregroundColor(.aiCoLabel)
//            }
//            .frame(width: 100, alignment: .trailing)
//        }
//        .padding(.vertical, 8)
//        .padding(.horizontal)
//    }
//}

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
                Text(coin.coinID)
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
