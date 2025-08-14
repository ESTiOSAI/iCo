//
//  CoinCell.swift
//  AIProject
//
//  Created by kangho lee on 8/7/25.
//

import SwiftUI

struct CoinListHeaderView: View {
    @Binding var sortCategory: SortCategory
    @Binding var nameSortOrder: SortOrder
    @Binding var volumeSortOrder: SortOrder
    
    var body: some View {
        HStack(spacing: 60) {
            SortToggleButton2(title: "한글명", sortCategory: .name, sortOrder: $nameSortOrder) {
                sortCategory = .name
                volumeSortOrder = .none
            }
            
            Spacer()
            
            SortToggleButton2(title: "거래대금", sortCategory: .volume, sortOrder: $volumeSortOrder) {
                sortCategory = .volume
                nameSortOrder = .none
            }
        }
        .frame(maxWidth: .infinity)
    }
}

struct CoinCell: View {
    
    let coin: CoinListModel
    @State var imageMap: [String: URL] = [:]
    
    var body: some View {
        VStack {
            HStack {
                // 코인 레이블
                HStack(spacing: 16) {
                    Group {
                        if let url = imageMap[coin.coinName] {
                            CachedAsyncImage(url: url)
                        } else {
                            Text(String(coin.coinName.prefix(1)))
                                .font(.caption.bold())
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                        }
                    }
                    .frame(width: 30, height: 30)
                    .clipShape(Circle())
                    .contentShape(Circle())
                    .overlay(
                        Circle().strokeBorder(Color.secondary.opacity(0.25), lineWidth: 1)
                    )
                    
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
                .font(.system(size: 12))
                .fontWeight(.medium)
                .foregroundStyle(.aiCoLabel)
                .frame(alignment: .leading)
                
                Spacer()
                
                CoinPriceView(change: coin.change, price: coin.currentPrice, rate: coin.changePrice, amount: coin.tradeAmount)
            }
        }
        .task {
            initialMap()
        }
    }
    
    func initialMap() {
        if let stringImageMap = UserDefaults.standard.object(forKey: AppStorageKey.imageMap) as? [String: String] {
            imageMap = stringImageMap.compactMapValues({ string in
                URL(string: string)
            })
        }
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
