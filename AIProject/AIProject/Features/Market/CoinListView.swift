//
//  CoinListView.swift
//  AIProject
//
//  Created by kangho lee on 7/30/25.
//

import SwiftUI

struct CoinListView: View {
    
    let viewModel = CoinListViewModel(socket: .init())
    
    var body: some View {
        VStack {
            
            List {
                CoinListHeaderView()
                    .fontWeight(.regular)
                    .font(.system(size: 11))
                    .foregroundStyle(.aiCoLabel)
                
                ForEach(viewModel.coins) { coin in
                    CoinCell(coin: coin)
                }
            }
            .task {
                await viewModel.connect()
                await viewModel.fetchInitial()
            }
            .onDisappear {
                viewModel.disconnect()
            }
        }
    }
}

fileprivate struct CoinListHeaderView: View {
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
                    .frame(maxWidth: 40, alignment: .trailing)
            }
            
            Text("거래대금")
        }
    }
}

fileprivate struct CoinCell: View {
    let coin: CoinListModel
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack(spacing: 8) {
                VStack(alignment: .leading) {
                    Text(coin.name)
                        .font(.system(size: 14))
                    
                    Text(coin.coinName)
                        .font(.system(size: 12))
                        .font(.callout)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: 100, alignment: .leading)
                
                Text(coin.currentPrice, format: .number)
                    .font(.system(size: 12))
                    .foregroundStyle(.red)
                    .frame(maxWidth: 75, alignment: .trailing)
                
                Text(coin.changePrice, format: .percent.precision(.fractionLength(2)))
                    .font(.system(size: 12))
                    .foregroundStyle(.red)
                    .frame(maxWidth: 40, alignment: .trailing)
                
                HStack(spacing: 0) {
                    Text(coin.tradeAmount, format: .number
                        .font(.system(size: 12))
                    Text("원")
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
    CoinListView()
}
