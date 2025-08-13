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
                    ForEach(RecommendCoin.dummyDatas) { coin in
                        RecommendCardView(recommendCoin: coin)
                            .containerRelativeFrame(.horizontal) { value, axis in
                                axis == .horizontal ? value * 0.7 : value
                            }
                    }
                }
                .padding(.horizontal)
                .scrollTargetLayout()
            }
            .scrollTargetBehavior(.viewAligned)
            .onAppear {
                Task {
                    await viewModel.loadRecommendCoin()
                }
            }
        }
        .padding(.vertical, 40)
        .background(LinearGradient(colors: [.aiBackgroundGradientProminent, .aiBackgroundGradientLight], startPoint: .topLeading, endPoint: .bottomTrailing))
    }
}

#Preview {
    RecommendCoinView()
}
