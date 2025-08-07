//
//  MarketView.swift
//  AIProject
//
//  Created by kangho lee on 7/31/25.
//

import SwiftUI

struct MarketView: View {
    @State var coins: [CoinListModel] = CoinListModel.preview
    var body: some View {
        NavigationStack {
            HeaderView(heading: "마켓", showSearchButton: true, isBookmarkView: true)
            CoinListView()
        }
    }
}

struct MockDetailView: View {
    var coin: CoinListModel
    
    var body: some View {
        VStack {
            Text(coin.name)
                .font(.largeTitle)
            
            Text("Coin Name: \(coin.coinName)")
                .font(.title2)
            
            Text("Current Price: \(coin.currentPrice, format: .number) 원")
                .font(.title3)
        }
        .padding()
    }
}
