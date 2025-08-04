//
//  CoinListView.swift
//  AIProject
//
//  Created by kangho lee on 7/30/25.
//

import SwiftUI

struct CoinListView: View {
    @State var coins: [CoinListModel]
    
    var body: some View {
        List {
            HStack(spacing: 60) {
                HStack {
                    Text("한글명")
                    Image(systemName: "arrow.up.arrow.down")
                }
                
                HStack {
                    Text("현재가")
                    
                    Text("전일대비")
                }
                
                Text("거래대금")
            }
            .fontWeight(.regular)
            .font(.system(size: 11))
            .foregroundStyle(.aiCoLabel)
            
            ForEach(coins) { coin in
                NavigationLink {
                    MockDetailView(coin: coin)
                } label: {
                    HStack {
                        HStack {
                            Image(systemName: "swift")
                            
                            VStack(alignment: .leading) {
                                Text(coin.name)
                                    .font(.system(size: 14))
                                
                                Text(coin.coinName)
                                    .font(.system(size: 12))
                                    .font(.callout)
                                    .foregroundStyle(.secondary)
                            }
                            .background(.red)
                            .frame(minWidth: 80, maxWidth: 100)
                        }
                        
                        Text(coin.currentPrice, format: .number)
                            .font(.system(size: 14))
                            .foregroundStyle(.red)
                        
                        Text(coin.changePrice, format: .percent.precision(.fractionLength(2)))
                            .font(.system(size: 14))
                            .foregroundStyle(.red)
                        
                        Text(162140000, format: .number)
                            .font(.system(size: 12))
                        Text("원")
                            .font(.system(size: 12))
                    }
                    .fontWeight(.medium)
                    .foregroundStyle(.aiCoLabel)                    
                }

            }
        }
    }
}

#Preview {
    CoinListView(coins: CoinListModel.preview)
}
