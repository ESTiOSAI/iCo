//
//  RecommendCoinView.swift
//  AIProject
//
//  Created by 강대훈 on 8/1/25.
//

import SwiftUI

struct RecommendCoinView: View {
    @EnvironmentObject var viewModel: RecommendCoinViewModel

    var body: some View {
        ZStack(alignment: .top) {
            LinearGradient(
                colors: [.aiBackgroundGradientLight, .aiBackgroundGradientProminent],
                startPoint: .topLeading,
                endPoint: .bottom
            )
            .frame(height: CardConst.headerHeight + CardConst.headerContentSpacing + (CardConst.cardHeight / 2))
            
            VStack(alignment: .center, spacing: CardConst.headerContentSpacing) {
                RecommendHeaderView()
                
                recommendContentView()
                    .frame(minHeight: CardConst.cardHeight)
            }
            .environmentObject(viewModel)
            .padding(.bottom, 30)
            
            VStack {
                Spacer()
                
                if viewModel.fetchTimestamp != nil {
                    TimestampWithRefreshButtonView(timestamp: viewModel.fetchTimestamp!, action: { viewModel.loadRecommendCoin() })
                        .padding(.horizontal, 16)
                }
            }
        }
        .padding(.bottom, 40)
    }
    
    @ViewBuilder
    func recommendContentView() -> some View {
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
                CoinCarouselView(viewModel: viewModel)
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
        .environmentObject(RecommendCoinViewModel())
}



