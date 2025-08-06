//
//  RecentSearchView.swift
//  AIProject
//
//  Created by 강대훈 on 8/5/25.
//

import SwiftUI

struct RecentSearchView: View {
    @ObservedObject var viewModel: SearchViewModel
    @State private var selectedCoin: Coin? = nil

    var body: some View {
        ScrollView {
            HStack {
                Text("최근 검색")
                    .padding(.vertical, 5)
                Spacer()
            }

            if viewModel.recentSearchCoins.isEmpty {
                HStack {
                    Text("검색 내역이 없어요.")
                        .font(.callout)
                        .foregroundStyle(.gray)
                    Spacer()
                }
            } else {
                ForEach(viewModel.recentSearchCoins) { coin in
                    HStack {
                        Image(systemName: "swift")
                        Text(coin.koreanName)
                            .bold()
                        Text(coin.id)
                            .font(.footnote)
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
                        viewModel.addRecentSearchKeyword(coin)
                        selectedCoin = coin
                    }
                }
                .padding(.vertical, 5)
                .navigationDestination(item: $selectedCoin) { coin in
                    CoinDetailView(coin: coin)
                }
            }
        }
        .padding()
        .onAppear {
            viewModel.loadRecentSearchKeyword()
        }
    }
}

#Preview {
    RecentSearchView(viewModel: SearchViewModel())
}
