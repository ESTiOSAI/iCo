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

            Group {
                switch viewModel.status {
                case .loading:
                    RecomendationPlaceholderCardView(status: .loading, message: "아이코가 추천할 코인을\n고르는 중이에요") {
                        Task { await viewModel.cancelTask() }
                    }
                case .success:
                    SuccessCoinView(viewModel: viewModel)
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
            .frame(height: .cardHeight)
            .padding(.bottom, 40)
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
    
    var body: some View {
        let recommendedCoins = viewModel.recommendCoins
        
        // TODO: cardID와 역할이 비슷하므로 추후에 합치기
        var currentIndex: Int = 1
        
        /// 무한 스크롤링 효과를 구현하기 위해 추천 코인 배열의 앞 뒤에 가짜 코인을 붙여주기
        var wrappedCoins: [RecommendCoin] {
            guard let first = recommendedCoins.first,
                  let last = recommendedCoins.last
            else { return [] }
            return [last] + recommendedCoins + [first]
        }
        
        var numberOfColumn: Int {
            if hSizeClass == .regular {
                return 2
            }
            
            return 1
        }
        
        GeometryReader { geoProxy in
            let spacing = 16.0
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .bottom, spacing: spacing) {
                    ForEach(wrappedCoins.indices, id: \.self) { index in
                        let coin = wrappedCoins[index]
                        
                        VStack {
                            RecommendCardView(recommendCoin: coin)
                                .id(index)
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
                .frame(height: .cardHeight + 1, alignment: .top)
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
            .onChange(of: cardID ?? 1, { _, newValue in
                currentIndex = newValue
            })
            .onReceive(viewModel.timer) { _ in // 타이머를 구독해 UI 업데이트하기
                guard !isDragging, !recommendedCoins.isEmpty else { return }
                
                // 카드 인덱스가 증가하면서 카드의 전체 값을 넘지 못하게 모듈러 연산 적용하기
                currentIndex = (currentIndex + 1) % wrappedCoins.count
                
                Task {
                    withAnimation(.easeInOut(duration: 0.5)) { // 애니메이션 지속 시간 지정하기
                        cardID = currentIndex
                    }
                    
                    // 가짜 코인 바꿔치기하기
                    try? await Task.sleep(nanoseconds: 500_000_000)
                    
                    // 스크롤 애니메이션이 끝난 후에 바꿔치기
                    if cardID == recommendedCoins.count + 1 { // 마지막 카드라면 첫 번째 카드로 바꿔치기
                        cardID = 1
                    } else if cardID == 0 { // 0번째 카드라면 마지막 카드로 바꿔치기: 실제 적용되는 경우는 없는 듯
                        cardID = recommendedCoins.count
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
