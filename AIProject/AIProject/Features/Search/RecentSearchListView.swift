//
//  RecentSearchListView.swift
//  AIProject
//
//  Created by 강대훈 on 8/6/25.
//

import SwiftUI

struct RecentSearchListView: View {
    @ObservedObject var viewModel: SearchViewModel
    @Binding var selectedCoin: Coin?
    
    var body: some View {
        ForEach(viewModel.recentSearchCoins) { coin in
            HStack {
                Image(systemName: "swift")
                Text(coin.koreanName)
                    .bold()
                Text(coin.id)
                    .font(.system(size: 13))
                    .foregroundStyle(.gray)

                Spacer()

                Button {
                    viewModel.removeRecentSearchKeyword(coin)
                } label: {
                    Image(systemName: "multiply")
                        .foregroundStyle(.aiCoPositive)
                }
            }
            .onTapGesture {
                viewModel.updateRecentSearchKeyword(coin)
                selectedCoin = coin
            }
        }
        .padding(.vertical, 5)
        .navigationDestination(item: $selectedCoin) { coin in
            CoinDetailView(coin: coin)
        }
    }
}

#Preview {
    RecentSearchListView(
        viewModel: SearchViewModel(),
        selectedCoin: .constant(Coin(id: "KRW-BTC", koreanName: "비트코인"))
    )
}
