//
//  RecommendCoinView.swift
//  AIProject
//
//  Created by 강대훈 on 8/1/25.
//

import SwiftUI

struct RecommendCoinView: View {
    @ObservedObject var viewModel: DashboardViewModel

    var body: some View {
        ScrollViewReader { _ in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
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
            .scrollTargetBehavior(.viewAligned)
        }
        .onAppear {
            Task {
                do {
                    try await viewModel.getRecommendCoin()
                } catch {
                    print(error.localizedDescription)
                }
            }
        }
    }
}

#Preview {
    RecommendCoinView(viewModel: DashboardViewModel())
}
