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
        .padding(.vertical, 25)
        .background(LinearGradient(colors: [.aiBackgroundGradientProminent, .aiBackgroundGradientLight], startPoint: .topLeading, endPoint: .bottomTrailing))
        .onAppear {
            Task {
                await viewModel.loadRecommendCoin()
            }
        }
    }
}

#Preview {
    RecommendCoinView()
}
