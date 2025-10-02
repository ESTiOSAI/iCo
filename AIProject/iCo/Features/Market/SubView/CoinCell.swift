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
    
    var body: some View {
        VStack {
            HStack {
                CoinMetaView(symbol: coin.coinSymbol, name: coin.koreanName, searchTerm: searchTerm)
                    .frame(alignment: .leading)
                
                Spacer()
                
                CoinPriceView(ticker: store)
                    .frame(alignment: .trailing)
                    .layoutPriority(1)
            }
        }
        .id(coin.id)
        .padding(.vertical, 18)
        .padding(.horizontal, 20)
        .contentShape(.rect)
    }
}

/// 변하지 않는 코인 메타 정보를 렌더링
fileprivate struct CoinMetaView: View {
    let symbol: String
    let name:String
    let searchTerm: String
    
    var body: some View {
        HStack(spacing: 16) {
            CoinView(symbol: symbol, size: 30)
            
            VStack(alignment: .leading, spacing: 6) {
                Text(name.highlighted(searchTerm))
                    .lineLimit(1)
                    .font(.system(size: name.count < 8 ? 14 : 12))
                    .fontWeight(.bold)
                
                Text(symbol.highlighted(searchTerm))
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
            }
        }
        .font(.system(size: 12))
        .fontWeight(.medium)
        .foregroundStyle(.aiCoLabel)
    }
}


/// 계속 바뀌는 코인 시세를 렌더링
fileprivate struct CoinPriceView: View {
    @EnvironmentObject var themeManager: ThemeManager
    
    /// 시세 정보 store
    var ticker: TickerStore
    
    /// 시세 layout shift를 막기 위해 사용되는 넓이 값
    @State private var priceWidth: CGFloat = 40
    
    /// 거래 layout shift를 막기 위해 사용되는 넓이 값
    @State private var volumeWidth: CGFloat = 40
    
    /// layout shift  보간 패딩
    private let pricePadding: CGFloat = 8
    
    private var changeColor: Color {
        switch ticker.snapshot.change {
        case .rise: return themeManager.selectedTheme.positiveColor
        case .even: return .aiCoLabel
        case .fall: return themeManager.selectedTheme.negativeColor
        }
    }
    
    var body: some View {
        VStack(alignment: .trailing, spacing: 6) {
            HStack(spacing: 0) {
                Text(ticker.snapshot.formatedRate)
                    .foregroundStyle(changeColor)
                
                Text(ticker.snapshot.formatedPrice)
                    .frame(minWidth: priceWidth, alignment: .trailing)
                    .font(.system(size: 15))
                    .blinkUnderlineOnChange(ticker.snapshot.price)
            }
            .frame(alignment: .trailing)
            
            HStack(spacing: 0) {
                Text("거래")
                    .font(.system(size: 11))
                Text(ticker.snapshot.formatedVolume)
                    .frame(minWidth: volumeWidth, alignment: .trailing)
            }
        }
        .font(.system(size: 12))
        .fontWeight(.medium)
        .foregroundStyle(.aiCoLabel)
        .background {
            VStack {
                ZStack {
                    Text(ticker.snapshot.formatedPrice)
                        .font(.system(size: 15))
                        .measureWidth { w in
                            priceWidth = w + pricePadding
                        }
                    Text(ticker.snapshot.formatedVolume)
                        .font(.system(size: 11))
                        .measureWidth { w in
                            volumeWidth = w + pricePadding
                        }
                }
                .monospacedDigit()
                .hidden()
            }
            .accessibilityHidden(true) // 최적화를 위해 사용
            .allowsHitTesting(false)
        }
    }
}

#Preview {
    VStack {
        CoinCell(coin: Coin(id: "KRW-BTC", koreanName: "비트코인"), store: .init(coinID: "KRW-BTC"), searchTerm: "비트")
            .frame(height: 100)
        CoinCell(coin: Coin(id: "KRW-BTC", koreanName: "비트코인8글자이름"), store: .init(coinID: "KRW-BTC"), searchTerm: "비트")
            .frame(height: 100)
    }
}

/// 레이블의 넓이를 가져오기 위한 key
private struct WidthKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

/// 값이 변경되면, closure를 실행 함
private extension View {
    func measureWidth(_ onChange: @escaping (CGFloat) -> Void) -> some View {
        background {
            GeometryReader { proxy in
                Color.clear
                    .preference(key: WidthKey.self, value: proxy.size.width)
            }
        }
        .onPreferenceChange(WidthKey.self, perform: onChange)
    }
}
