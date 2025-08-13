//
//  RecommendCoinView.swift
//  AIProject
//
//  Created by 강대훈 on 8/1/25.
//

import SwiftUI

struct RecommendCoinView: View {
    @StateObject private var viewModel = RecommendCoinViewModel()

    var body: some View {
        ZStack {
            SuccessCoinView(viewModel: viewModel)
                .opacity(viewModel.isSuccess ? 1 : 0)

            switch viewModel.status {
            case .loading:
                DefaultProgressView(status: .loading, message: "이용자에 맞는 코인을 분석중이에요") {
                    viewModel.cancelTask()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            case .failure(let networkError):
                DefaultProgressView(status: .failure,message: networkError.localizedDescription) {
                    viewModel.loadRecommendCoin()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            case .cancel(let networkError):
                DefaultProgressView(status: .cancel, message: networkError.localizedDescription) {
                    viewModel.loadRecommendCoin()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            default:
                EmptyView()
            }
        }
        .background(LinearGradient(colors: [.aiBackgroundGradientProminent, .aiBackgroundGradientLight], startPoint: .topLeading, endPoint: .bottomTrailing))
        .onAppear {
            viewModel.loadRecommendCoin()
        }
    }
}

struct SuccessCoinView: View {
    @ObservedObject var viewModel: RecommendCoinViewModel

    var body: some View {
        VStack(spacing: 30) {
            SubheaderView(
                imageName: "sparkles",
                subheading: "이런 코인은 어떠세요?",
                description: "회원님의 관심 코인을 기반으로\n새로운 코인을 추천해드려요",
                imageColor: .aiCoBackgroundWhite,
                fontColor: .aiCoBackgroundWhite
            )

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(viewModel.recommendCoins) { coin in
                        RecommendCardView(recommendCoin: coin)
                            .containerRelativeFrame(.horizontal) { value, axis in
                                axis == .horizontal ? value * 0.7 : value
                            }
                    }
                }
                .padding(.horizontal)
                .scrollTargetLayout()
            }
            .frame(height: 300)
            .scrollTargetBehavior(.viewAligned)
        }
        .padding(.vertical, 40)
    }
}

#Preview {
    RecommendCoinView()
}
