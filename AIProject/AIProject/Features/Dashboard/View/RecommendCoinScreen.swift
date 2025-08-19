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
    @State var selectedCoin: RecommendCoin?
    
    @State var cardID: Int?
    
    var body: some View {
        let recommendedCoins = viewModel.recommendCoins
        
        var currentIndex: Int = 1
        
        var wrappedCoins: [RecommendCoin] {
            guard let first = recommendedCoins.first,
                  let last = recommendedCoins.last else { return [] }
            return [last] + recommendedCoins + [first]
        }
        
        GeometryReader { geoProxy in
            let horizonInset = geoProxy.size.width * 0.1
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    let cardWidth = geoProxy.size.width * 0.8
                    
                    ForEach(wrappedCoins.indices, id: \.self) { index in
                        let coin = wrappedCoins[index]
                        
                        VStack {
                            RecommendCardView(recommendCoin: coin)
                                .id(index)
                                .frame(width: cardWidth, height: cardID == index ? 300 : 260)
                                .onTapGesture { selectedCoin = coin }
                        }
                    }
                }
                .scrollTargetLayout()
            }
            .contentMargins(.horizontal, horizonInset)
            .scrollTargetBehavior(.viewAligned)
            .scrollPosition(id: $cardID)
            .simultaneousGesture(DragGesture()
                .updating($isDragging) { _, state, _ in
                    state = true
                }
                .onEnded({ _ in
                    viewModel.stopTimer()
                    viewModel.startTimer()
                }
            ))
            .onChange(of: cardID ?? 1, { _, newValue in
                currentIndex = newValue
            })
            .onReceive(viewModel.timer) { _ in
                guard !isDragging, !recommendedCoins.isEmpty else { return }
                
                currentIndex = (currentIndex + 1) % wrappedCoins.count
                
                Task {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        cardID = currentIndex
                    }
                    try? await Task.sleep(nanoseconds: 500_000_000)
                    
                    await MainActor.run {
                        if cardID == recommendedCoins.count + 1 {
                            cardID = 1
                        } else if cardID == 0 {
                            cardID = recommendedCoins.count
                        }
                    }
                }
            }
            .navigationDestination(item: $selectedCoin) { coin in
                CoinDetailView(coin: Coin(id: coin.id, koreanName: coin.name, imageURL: coin.imageURL))
            }
            .onAppear {
                cardID = 1
                viewModel.startTimer()
            }
            .onDisappear {
                viewModel.stopTimer()
            }
        }
    }
}
