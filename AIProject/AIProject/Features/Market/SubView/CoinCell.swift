//
//  CoinCell.swift
//  AIProject
//
//  Created by kangho lee on 8/7/25.
//

import SwiftUI

struct CoinCell: View {
    let coin: Coin
    let store: TickerStore
    
    init(coin: Coin, store: TickerStore) {
        self.coin = coin
        self.store = store
    }
    
    var body: some View {
        VStack {
            HStack {
                
                #if DEBUG
//                let _ = Self._printChanges()
                #endif
                // 코인 레이블
                CoinMetaView(symbol: coin.coinSymbol, name: coin.koreanName)
                    .frame(alignment: .leading)
                
                CoinPriceView(ticker: store)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
        }
        .id(coin.id)
        .padding(.vertical, 10)
        .contentShape(.rect)
    }
}

fileprivate struct CoinMetaView: View {
    let symbol: String
    let name:String
    
    var body: some View {
        HStack(spacing: 16) {
            CoinView(symbol: symbol, size: 30)
            
            VStack(alignment: .leading, spacing: 6) {
                Text(name)
                    .lineLimit(2)
                    .font(.system(size: 14))
                    .fontWeight(.bold)
                
                Text(symbol)
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
            }
        }
        .font(.system(size: 12))
        .fontWeight(.medium)
        .foregroundStyle(.aiCoLabel)
        .frame(alignment: .leading)
    }
}

fileprivate struct CoinPriceView: View {
    let ticker: TickerStore
    
    var changeColor: Color {
        switch ticker.snapshot.change {
        case .rise: return .aiCoPositive
        case .even: return .aiCoLabel
        case .fall: return .aiCoNegative
        }
    }
    
    var code: String {
        switch ticker.snapshot.change {
        case .rise: return "▲"
        case .even: return ""
        case .fall: return "▼"
        }
    }
    
    var body: some View {
        VStack(alignment: .trailing, spacing: 6) {
            
            #if DEBUG
            // FIXME: volume과 rate은 한 번에 변하는데 각각 rendering되고 있음
//            let _ = Self._printChanges()
            #endif
            
            HStack {
                HStack(spacing: 0) {
                    Text(code)
                    Text(ticker.snapshot.rate, format: .percent.precision(.fractionLength(2)))
                }
                .foregroundStyle(changeColor)
                
                HStack(spacing: 0) {
                    Text(ticker.snapshot.price, format: .number)
                        
                    Text("원")
                }
                .font(.system(size: 15))
                .blinkBorderOnChange(ticker.snapshot.price, duration: .milliseconds(500), color: .aiCoLabel, lineWidth: 1, cornerRadius: 0)
            }
            HStack(spacing: 4) {
                Text("거래")
                    .font(.system(size: 11))
                Text(ticker.snapshot.volume.formatMillion)
            }
        }
        .font(.system(size: 12))
        .fontWeight(.medium)
        .foregroundStyle(.aiCoLabel)
        .frame(maxWidth: .infinity, alignment: .trailing)
    }
}
