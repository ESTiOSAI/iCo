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
        VStack(alignment: .center, spacing: .headerContentSpacing) {
            RecommendHeaderView()
            
            coinContentView()
                .frame(minHeight: .cardHeight)
                .padding(.bottom, 40)
        }
    }

    @ViewBuilder
    func coinContentView() -> some View {
        switch viewModel.status {
        case .loading:
            RecomendationPlaceholderCardView(status: .loading, message: "아이코가 추천할 코인을\n고르는 중이에요") {
                Task { await viewModel.cancelTask() }
            }
        case .success:
            if !(viewModel.recommendCoins.count > 0) {
                // 최종적으로 반환된 코인이 1개도 없을 때
                RecomendationPlaceholderCardView(status: .failure, message: "추천할 코인을 찾지 못했어요\n잠시 후 다시 시도해주세요") {
                    viewModel.loadRecommendCoin()
                }
            } else {
                SuccessCoinView(viewModel: viewModel)
            }
        case .failure(let networkError):
            RecomendationPlaceholderCardView(status: .failure, message: networkError.localizedDescription) {
                viewModel.loadRecommendCoin()
            }
        case .cancel(let networkError):
            RecomendationPlaceholderCardView(status: .cancel, message: networkError.localizedDescription) {
                viewModel.loadRecommendCoin()
            }
        }
    }
}

#Preview {
    RecommendCoinView()
}

struct SuccessCoinView: View {
    @ObservedObject var viewModel: RecommendCoinViewModel
    @Environment(\.horizontalSizeClass) private var hSizeClass

    @GestureState var isDragging: Bool = false
    @State var selectedCoin: RecommendCoin?
    
    /// 현재 추천 코인 카드의 인덱스를 저장하며,
    /// 선택된 카드의 위치를 추적하고 스크롤 포지션을 관리하는 데 사용하는 상태 변수
    @State var cardID: Int?
    
    @State var wrappedCoins = [[RecommendCoin]]()
    
    var body: some View {
        let recommendedCoins = viewModel.recommendCoins
        
        var numberOfColumn: Int {
            if hSizeClass == .regular {
                return 2
            }
            
            return 1
        }
        
        let tempCoinArray = wrappedCoins.flatMap { $0.map { $0 } }
        
        GeometryReader { geoProxy in
            let spacing = 16.0
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .bottom, spacing: spacing) {
                    ForEach(tempCoinArray.indices, id: \.self) { index in
                        let coin = tempCoinArray[index]
                        
                        VStack {
                            RecommendCardView(recommendCoin: coin)
                                .frame(
                                    width: .infinity,
                                    height: .cardHeight
                                )
                                .onTapGesture { selectedCoin = coin }
                                .scrollTransition(axis: .horizontal) { content, phase in // 활성화된 코인은 크게 보이게 하기
                                    content.scaleEffect(
                                        y: phase.isIdentity ? 1 : .cardHeightMultiplier,
                                        anchor: .bottom
                                    )
                                }
                        }
                        .containerRelativeFrame(
                            .horizontal,
                            count: numberOfColumn,
                            spacing: spacing
                        )
                    }
                }
                .scrollTargetLayout()
                .frame(height: .cardHeight + 1, alignment: .top) // stroke가 잘려보이는 듯 해서 1 포인트 추가하기
            }
            .contentMargins(.horizontal, 20 * 2)
            .scrollTargetBehavior(.viewAligned)
            .scrollPosition(id: $cardID, anchor: .leading)
            .simultaneousGesture(DragGesture()
                .updating($isDragging) { _, state, _ in
                    state = true
                }
                .onEnded({ _ in
                    // 사용자가 스크롤링 한 후에는 타이머를 초기화하기
                    viewModel.stopTimer()
                    viewModel.startTimer()
                }
            ))
            .onReceive(viewModel.timer) { _ in // 타이머를 구독해 UI 업데이트하기
                guard !isDragging,
                      !recommendedCoins.isEmpty,
                      let cardID
                else { return }

                let totalCoinCount = recommendedCoins.count
                
                let position = cardID / totalCoinCount // 0: 첫 배열, 1: 중간, 2: 마지막
                let indexInGroup = cardID % totalCoinCount

                switch (position, indexInGroup) {
                case (0, totalCoinCount - 1):
                    print("첫 번째 배열의 마지막 코인에 도달: 맨 뒤의 배열 삭제 + 앞에 새로운 배열 추가")
                    
                    Task {
                        try? await Task.sleep(nanoseconds: 500_000_000)
                        wrappedCoins.removeLast()
                        wrappedCoins.insert(recommendedCoins, at: 0)
                        self.cardID = cardID + totalCoinCount
                    }
                    
                    return
                case (2, 0):
                    print("마지막 배열의 첫 번째 코인에 도달: 맨 앞의 배열 삭제 + 뒤에 새로운 배열 추가")
                    
                    Task {
                        try? await Task.sleep(nanoseconds: 500_000_000)
                        wrappedCoins.removeFirst()
                        wrappedCoins.append(recommendedCoins)
                        self.cardID = cardID - totalCoinCount
                    }
                    return
                default:
                    Task {
                        withAnimation(.easeInOut(duration: 0.5)) {
                            self.cardID = (cardID + 1) % (totalCoinCount * 3)
                        }
                    }
                }
            }
            .navigationDestination(item: $selectedCoin) { coin in
                CoinDetailView(coin: Coin(id: coin.id, koreanName: coin.name, imageURL: coin.imageURL))
            }
            .onAppear {
                /// 무한 스크롤링 효과를 구현하기 위해 추천 코인 배열의 앞 뒤에 가짜 코인을 붙여주기
                wrappedCoins = [recommendedCoins, recommendedCoins, recommendedCoins]
                cardID = recommendedCoins.count
                viewModel.startTimer()
            }
            .onDisappear {
                viewModel.stopTimer()
                wrappedCoins.removeAll()
            }
        }
    }
}
