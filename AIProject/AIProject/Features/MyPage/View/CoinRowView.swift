//
//  CoinRowView.swift
//  AIProject
//
//  Created by 백현진 on 8/3/25.
//

import SwiftUI

struct CoinRowView: View {
    let coin: CoinListModel

    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            HStack(spacing: 8) {
                Image(systemName: "bitcoinsign.circle.fill")
                    .resizable()
                    .frame(width: 30, height: 30)
                    .background(Circle().fill(.yellow))
                    .clipShape(Circle())

                VStack(alignment: .leading, spacing: 2) {
                    Text(coin.name)
                        .font(.system(size: 15))
                        .foregroundColor(.aiCoLabel)

                    Text(coin.coinID)
                        .font(.caption)
                        .foregroundColor(.aiCoLabelSecondary)
                }

            }
            .frame(maxWidth: .infinity, alignment: .leading)

            // 가격
            VStack(alignment: .trailing, spacing: 2) {
                HStack(spacing: 2) {
                    Text(coin.currentPrice, format: .number)
                        .foregroundColor(Color.aiCoLabel)
                        .font(.subheadline)

                    Text("원")
                        .foregroundColor(Color.aiCoLabel)
                        .font(.system(size: 12))
                }

                HStack(spacing: 2) {
                    Text(coin.changePrice, format: .number)
                        .font(.caption)
                        .foregroundColor(Color.aiCoPositive)
                    
                    Text("%")
                        .foregroundColor(Color.aiCoPositive)
                        .font(.system(size: 10))
                }
            }
            .frame(width: 100, alignment: .trailing)

            // 거래 대금
            VStack(alignment: .trailing, spacing: 2) {
                HStack(spacing: 2) {
                    Text(coin.tradeAmount.formattedVolumePrice)
                }
                .font(.system(size: 15))
                .foregroundColor(.aiCoLabel)
            }
            .frame(width: 100, alignment: .trailing)
        }
        .padding(.vertical, 8)
        .padding(.horizontal)
    }
}

extension Double {
    /// 백만 단위 거래 대금 포맷 + 천 단위 쉼표
    var formattedVolumePrice: String {
        let millionUnit = Int(self / 1_000_000)
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal

        let formatted = numberFormatter.string(from: NSNumber(value: millionUnit)) ?? "\(millionUnit)"
        return "\(formatted)백만"
    }
}
