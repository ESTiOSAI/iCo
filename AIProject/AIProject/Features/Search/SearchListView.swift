//
//  SearchListView.swift
//  AIProject
//
//  Created by 강대훈 on 8/11/25.
//

import SwiftUI

struct SearchListView: View {
    @ObservedObject var viewModel: SearchViewModel
    @Binding var selectedCoin: Coin?

    let isRecentSearch: Bool

    var body: some View {
        ScrollView {
            LazyVStack {
                Group {
                    ForEach(isRecentSearch ? viewModel.recentSearchCoins : viewModel.relatedCoins) { coin in
                        HStack {
                            AsyncImage(url: coin.imageURL) { image in
                                image
                                    .resizable()
                                    .frame(width: 20, height: 20)
                                    .clipShape(Circle())
                                    .overlay {
                                        Circle()
                                            .stroke(Gradient.aiCoGradientStyle(.default), lineWidth: 0.5)
                                    }
                            } placeholder: {
                                Text(String(coin.id.prefix(1)))
                                    .font(.system(size: 11))
                                    .foregroundStyle(.aiCoAccent)
                                    .frame(width: 20, height: 20)
                                    .overlay {
                                        Circle()
                                            .stroke(.default, lineWidth: 0.5)
                                    }
                            }
                            
                            Text(coin.koreanName)
                                .font(.system(size: 15))
                                .foregroundStyle(.aiCoLabel)
                                .fontWeight(.bold)
                            Text(coin.id)
                                .font(.system(size: 12))
                                .foregroundStyle(.aiCoLabelSecondary)
                                .fontWeight(.semibold)

                            Spacer()

                            if isRecentSearch {
                                CircleDeleteButton(fontSize: 9) {
                                    viewModel.removeRecentSearchKeyword(coin)
                                }
                            }
                        }
                        .onTapGesture {
                            viewModel.updateRecentSearchKeyword(coin)
                            selectedCoin = coin
                        }
                    }
                }
                .padding(.vertical, 5)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .overlay {
                RoundedRectangle(cornerRadius: 15)
                    .stroke(Gradient.aiCoGradientStyle(.default), lineWidth: 0.5)
            }
            .background {
                RoundedRectangle(cornerRadius: 15)
                    .fill(.aiCoBackground)
            }
            .navigationDestination(item: $selectedCoin) { coin in
                CoinDetailView(coin: coin)
            }
        }
        .scrollIndicators(.hidden)
    }
}
