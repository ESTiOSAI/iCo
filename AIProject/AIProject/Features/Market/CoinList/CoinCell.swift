//
//  CoinCell.swift
//  AIProject
//
//  Created by kangho lee on 8/7/25.
//

import SwiftUI

struct CoinListHeaderView: View {
    @Binding var selected: Bool
    
    var body: some View {
        HStack(spacing: 60) {
            HStack {
                Text("한글명")
                RoundedButton(title: nil, imageName: "chevron.down") {
                    
                }
            }
            
            Text("현재가")
        }
        .fontWeight(.medium)
        .font(.system(size: 12))
        .foregroundStyle(.aiCoLabelSecondary)
    }
}

struct CoinCell: View {
    let coin: CoinListModel
    
    var body: some View {
        HStack {
            
            // 코인 레이블
            HStack(spacing: 16) {
                Image(systemName: "swift")
                    .frame(width: 30, height: 30)
                VStack(alignment: .leading, spacing: 6) {
                    Text(coin.name)
                        .lineLimit(2)
                        .font(.system(size: 14))
                        .fontWeight(.bold)
                    
                    Text(coin.coinName)
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary)
                }
            }
            .frame(alignment: .leading)
            
            Spacer()
            
            CoinPriceView(change: coin.change, price: coin.currentPrice, rate: coin.changePrice, amount: coin.tradeAmount)
        }
        .font(.system(size: 12))
        .fontWeight(.medium)
        .foregroundStyle(.aiCoLabel)
    }
}

fileprivate struct CoinPriceView: View {
    let change: CoinListModel.TickerChangeType
    let price: Double
    let rate: Double
    let amount: Double
    
    init(change: CoinListModel.TickerChangeType, price: Double, rate: Double, amount: Double) {
        self.change = change
        self.price = price
        self.rate = rate
        self.amount = amount
    }
    
    var changeColor: Color {
        switch change {
        case .rise: return .aiCoPositive
        case .even: return .aiCoLabel
        case .fall: return .aiCoNegative
        }
    }
    
    var code: String {
        switch change {
        case .rise: return "▲"
        case .even: return ""
        case .fall: return "▼"
        }
    }
    
    var body: some View {
        VStack(alignment: .trailing, spacing: 6) {
            HStack {
                HStack(spacing: 0) {
                    Text(code)
                    Text(rate, format: .percent.precision(.fractionLength(2)))
                }
                .foregroundStyle(changeColor)
                
                HStack(spacing: 0) {
                    Text(price, format: .number)
                    Text("원")
                }
                .font(.system(size: 15))
            }
            HStack(spacing: 4) {
                Text("거래")
                    .font(.system(size: 11))
                Text(amount.formatMillion)
            }
        }
        .font(.system(size: 12))
        .fontWeight(.medium)
        .foregroundStyle(.aiCoLabel)
        .frame(maxWidth: .infinity, alignment: .trailing)
    }
}

#Preview {
    VStack {
        CoinListHeaderView()
        CoinCell(coin: CoinListModel.preview[0])
    }
    .padding(.horizontal)
}
