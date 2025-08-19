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
                    DefaultProgressView(status: .loading, message: "아이코가 추천할 코인을\n고르는 중이에요") {
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

#Preview {
    RecommendCoinView()
}

struct SuccessCoinView: View {
    @ObservedObject var viewModel: RecommendCoinViewModel

    @GestureState var isDragging: Bool = false
    @State var selection: String?
    @State var selectedCoin: RecommendCoin?
    
    var body: some View {
        let recommendedCoins = viewModel.recommendCoins
        var currentIndex = viewModel.currentIndex
        
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
            .simultaneousGesture(DragGesture()
                .updating($isDragging) { _, state, _ in
                    state = true
                }
                .onEnded({ _ in
                    viewModel.stopTimer()
                    viewModel.startTimer()
                }
            ))
            .onChange(of: viewModel.recommendCoins.count) {
                guard !viewModel.recommendCoins.isEmpty else { return }
                selection = viewModel.recommendCoins[0].id
            }
            .onChange(of: selection) {
                if let selection {
                    if let index = recommendedCoins.firstIndex(where: { $0.id == selection }) {
                        currentIndex = index
                    }
                }
            }
            .onReceive(viewModel.timer) { _ in
                guard !isDragging, !recommendedCoins.isEmpty else { return }
                currentIndex += 1

                withAnimation(.easeInOut) {
                    selection = recommendedCoins[currentIndex].id
                }
            }
            .navigationDestination(item: $selectedCoin) { coin in
                CoinDetailView(coin: Coin(id: coin.id, koreanName: coin.name, imageURL: coin.imageURL))
            }
            .onAppear {
                selection = viewModel.recommendCoins[0].id
                viewModel.startTimer()
            }
            .onDisappear {
                viewModel.stopTimer()
                currentIndex = 0
            }
        }
    }
}
