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
        Group {
            switch viewModel.state {
            case .loading:
                Text("코인을 추천중입니다..")
            case .success(let recommendCoins):
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(recommendCoins) { coin in
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
            case .failure(let error):
                VStack {
                    Text("코인 추천을 받지 못했어요.")
                    Button {
                        Task {
                            await viewModel.loadRecommendCoin()
                        }
                    } label: {
                        Text("다시 시도하기")
                    }
                }
            }
        }
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
