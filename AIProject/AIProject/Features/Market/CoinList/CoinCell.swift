//
//  CoinCell.swift
//  AIProject
//
//  Created by kangho lee on 8/7/25.
//

import SwiftUI

struct CoinListHeaderView: View {
    var body: some View {
        HStack(spacing: 60) {
            HStack {
                Text("한글명")
                Image(systemName: "arrow.up.arrow.down")
            }
            
            HStack {
                Text("현재가")
                    .frame(maxWidth: 80, alignment: .trailing)
                
                Text("전일대비")
                    .frame(maxWidth: 55, alignment: .trailing)
            }
            
            Text("거래대금")
        }
    }
}

struct CoinCell: View {
    let coin: CoinListModel
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack(spacing: 4) {
                VStack(alignment: .leading) {
                    Text(coin.name)
                        .lineLimit(2)
                        .font(.system(size: 14))
                    
                    Text(coin.coinName)
                        .font(.system(size: 12))
                        .font(.callout)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: 100, alignment: .leading)
                
                Text(coin.currentPrice, format: .number)
                    .font(.system(size: 12))
                    .foregroundStyle(coin.change == .rise ? .red : .blue)
                    .frame(maxWidth: 75, alignment: .trailing)
                
                Text(coin.changePrice, format: .percent.precision(.fractionLength(2)))
                    .font(.system(size: 12))
                    .foregroundStyle(coin.change == .rise ? .red : .blue)
                    .frame(maxWidth: 55, alignment: .trailing)
                
                HStack(spacing: 0) {
                    Text(coin.tradeAmount.formatMillion)
                        .font(.system(size: 12))
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
            }
            .fontWeight(.medium)
            .foregroundStyle(.aiCoLabel)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

#Preview {
    CoinCell(coin: CoinListModel.preview[0])
}
