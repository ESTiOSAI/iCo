//
//  SearchResultListView.swift
//  AIProject
//
//  Created by 강대훈 on 8/6/25.
//

import SwiftUI

struct SearchResultListView: View {
    @ObservedObject var viewModel: SearchViewModel
    @Binding var selectedCoin: Coin?

    var body: some View {
        List {
            ForEach(viewModel.relatedCoins) { coin in
                HStack {
                    Image(systemName: "swift")
                    Text(coin.koreanName)
                    Text(coin.id)
                        .font(.system(size: 13))
                        .foregroundStyle(.gray)
                    Spacer()
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    viewModel.updateRecentSearchKeyword(coin)
                    selectedCoin = coin
                }
            }
        }
        .navigationDestination(item: $selectedCoin) { coin in
            CoinDetailView(coin: coin)
        }
    }
}

#Preview {
    SearchResultListView(
        viewModel: SearchViewModel(),
        selectedCoin: .constant(Coin(id: "KRW-BTC", koreanName: "비트코인"))
    )
}
