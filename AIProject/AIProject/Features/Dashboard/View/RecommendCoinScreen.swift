//
//  RecommendCoinScreen.swift
//  AIProject
//
//  Created by 강대훈 on 8/15/25.
//

import SwiftUI

struct RecommendCoinScreen: View {
    @ObservedObject var viewModel: RecommendCoinViewModel

    var body: some View {
        VStack(spacing: 60) {
            RecommendHeaderView()

            Group {
                switch viewModel.status {
                case .loading:
                    DefaultProgressView(status: .loading, message: "이용자에 맞는 코인을 분석중이에요") {
                        Task {
                            await viewModel.cancelTask()
                        }
                    }
                    .padding(.horizontal, 16)
                case .success:
                    SuccessCoinView(viewModel: viewModel)
                case .failure(let networkError):
                    DefaultProgressView(status: .failure, message: networkError.localizedDescription) {
                        viewModel.loadRecommendCoin()
                    }
                case .cancel(let networkError):
                    DefaultProgressView(status: .cancel, message: networkError.localizedDescription) {
                        viewModel.loadRecommendCoin()
                    }
                }
            }
            .frame(minHeight: 300)
            .padding(.bottom, 40)
        }
    }
}

struct SuccessCoinView: View {
    @ObservedObject var viewModel: RecommendCoinViewModel

    @GestureState var isDragging: Bool = false
    @State var selection: String?
    @State var selectedCoin: RecommendCoin?

    var currentIndex: Int = 0

    var body: some View {
        GeometryReader { geoProxy in
            let horizonInset = geoProxy.size.width * 0.15

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(viewModel.recommendCoins) { coin in
                        RecommendCardView(recommendCoin: coin)
                            .id(coin.id)
                            .frame(width: geoProxy.size.width * 0.7)
                            .onTapGesture {
                                selectedCoin = coin
                            }
                    }
                }
                .scrollTargetLayout()
            }
            .contentMargins(.horizontal, horizonInset)
            .scrollTargetBehavior(.viewAligned)
            .scrollPosition(id: $selection)
            .simultaneousGesture(DragGesture().updating($isDragging) { _, state, _ in
                state = true
            })
            .onChange(of: viewModel.recommendCoins.count) {
                guard !viewModel.recommendCoins.isEmpty else { return }
                selection = viewModel.recommendCoins[0].id
            }
            .onChange(of: selection) {
                if let selection {
                    if let index = viewModel.recommendCoins.firstIndex(where: { $0.id == selection }) {
                        viewModel.currentIndex = index
                    }
                }
            }
            .onReceive(viewModel.timer) { _ in
                guard !isDragging, !viewModel.recommendCoins.isEmpty else { return }
                viewModel.currentIndex = (viewModel.currentIndex + 1) % viewModel.recommendCoins.count

                withAnimation(.easeInOut) {
                    selection = viewModel.recommendCoins[viewModel.currentIndex].id
                }
            }
            .navigationDestination(item: $selectedCoin) { coin in
                CoinDetailView(coin: Coin(id: coin.id, koreanName: coin.name, imageURL: coin.imageURL))
            }
        }
    }
}
