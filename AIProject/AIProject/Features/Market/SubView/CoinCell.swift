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
    let searchTerm: String
    
    init(coin: Coin, store: TickerStore, searchTerm: String) {
        self.coin = coin
        self.store = store
        self.searchTerm = searchTerm
    }
    
    var body: some View {
        VStack {
            HStack {
                CoinMetaView(symbol: coin.coinSymbol, name: coin.koreanName, searchTerm: searchTerm)
                    .frame(alignment: .leading)
                
                CoinPriceView(ticker: store)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
        }
        .id(coin.id)
        .padding(.vertical, 18)
        .padding(.horizontal, 20)
        .contentShape(.rect)
    }
}

fileprivate struct CoinMetaView: View {
    let symbol: String
    let name:String
    let searchTerm: String
    
    var body: some View {
        HStack(spacing: 16) {
            CoinView(symbol: symbol, size: 30)
            
            VStack(alignment: .leading, spacing: 6) {
                Text(name.highlighted(searchTerm))
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
    @EnvironmentObject var themeManager: ThemeManager
    
    let ticker: TickerStore
    
    private var changeColor: Color {
        switch ticker.snapshot.change {
        case .rise: return themeManager.selectedTheme.positiveColor
        case .even: return .aiCoLabel
        case .fall: return themeManager.selectedTheme.negativeColor
        }
    }
    
    private var animationColor: Color {
        switch ticker.snapshot.change {
        case .rise: return themeManager.selectedTheme.positiveColor
        case .even: return .clear
        case .fall: return themeManager.selectedTheme.negativeColor
        }
    }
    
    private var code: String {
        switch ticker.snapshot.change {
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
                    Text(ticker.snapshot.rate, format: .percent.precision(.fractionLength(2)))
                }
                .foregroundStyle(changeColor)
                
                HStack(spacing: 0) {
                    Text(ticker.snapshot.price, format: .number)
                    
                    
                    Text("원")
                }
                .font(.system(size: 15))
                .background {
                    GeometryReader { proxy in
                        Rectangle()
                            .fill(.clear)
                            .frame(width: proxy.size.width, height: 1)
                            .blinkBorderOnChange(ticker.snapshot.price, duration: .milliseconds(400), color: .aiCoLabel, lineWidth: 1, cornerRadius:0.5)
                            .offset(y: proxy.size.height + 1)
                    }
                }
            }
            .frame(alignment: .trailing)
            
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

#Preview {
    VStack {
        CoinCell(coin: Coin(id: "KRW-BTC", koreanName: "비트코인"), store: .init(coinID: "KRW-BTC"), searchTerm: "비트")
            .frame(height: 100)
        CoinCell(coin: Coin(id: "KRW-BTC", koreanName: "비트코인"), store: .init(coinID: "KRW-BTC"), searchTerm: "비트")
            .frame(height: 100)
    }
}
