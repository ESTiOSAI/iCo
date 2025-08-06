//
//  RelatedKeywordView.swift
//  AIProject
//
//  Created by 강대훈 on 8/5/25.
//

import SwiftUI

struct RelatedKeywordView: View {
    @ObservedObject var viewModel: SearchViewModel
    @State private var selectedCoin: Coin? = nil

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
    RelatedKeywordView(viewModel: SearchViewModel())
}
