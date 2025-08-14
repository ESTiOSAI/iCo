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
            LinearGradient(colors: [.aiBackgroundGradientProminent, .aiBackgroundGradientLight], startPoint: .top, endPoint: .bottom)

            SuccessCoinView(viewModel: viewModel)
                .opacity(viewModel.isSuccess ? 1 : 0)

            Group {
                switch viewModel.status {
                case .loading:
                    DefaultProgressView(status: .loading, message: "이용자에 맞는 코인을 분석중이에요", buttonAction: {
                        viewModel.cancelTask()
                    }, backgroundColor: .clear)
                case .failure(let networkError):
                    DefaultProgressView(status: .failure, message: networkError.localizedDescription, buttonAction: {
                        viewModel.loadRecommendCoin()
                    }, backgroundColor: .clear)
                case .cancel(let networkError):
                    DefaultProgressView(status: .cancel, message: networkError.localizedDescription, buttonAction: {
                        viewModel.loadRecommendCoin()
                    }, backgroundColor: .clear)
                default:
                    EmptyView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

struct SuccessCoinView: View {
    @ObservedObject var viewModel: RecommendCoinViewModel

    @GestureState var isDragging: Bool = false
    @State var selection: String?

    var timer = Timer.publish(every: 3, on: .main, in: .common).autoconnect()
    var currentIndex: Int = 0

    var body: some View {
        VStack(spacing: 60) {
            VStack(spacing: 0) {
                HStack {
                    Text("대시보드")
                        .font(.system(size: 30, weight: .bold))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundStyle(.aiCoBackgroundWhite)
                .padding(.top, 70)
                .padding(.bottom, 20)
                .padding(.horizontal, 16)


                SubheaderView(
                    imageName: "sparkles",
                    subheading: "이런 코인은 어떠세요?",
                    description: "회원님의 관심 코인을 기반으로\n새로운 코인을 추천해드려요",
                    imageColor: .aiCoBackgroundWhite,
                    fontColor: .aiCoBackgroundWhite
                )
            }

            GeometryReader { geoProxy in
                let horizonInset = geoProxy.size.width * 0.15

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(viewModel.recommendCoins) { coin in
                            RecommendCardView(recommendCoin: coin)
                                .id(coin.id)
                                .frame(width: geoProxy.size.width * 0.7)
                        }
                    }
                    .scrollTargetLayout()
                }
                .contentMargins(.horizontal, horizonInset)
                .scrollTargetBehavior(.viewAligned)
                .scrollPosition(id: $selection)
                .simultaneousGesture(DragGesture().updating($isDragging) { _, state, _ in
					state = true
                })
                .onChange(of: viewModel.recommendCoins.count) {
                    guard !viewModel.recommendCoins.isEmpty else { return }
                    selection = viewModel.recommendCoins[0].id
                }
                .onChange(of: selection) {
                    if let selection {
                        if let index = viewModel.recommendCoins.firstIndex(where: { $0.id == selection }) {
                            viewModel.currentIndex = index
                        }
                    }
                }
                .onReceive(timer) { _ in
                    guard !isDragging, !viewModel.recommendCoins.isEmpty else { return }
                    viewModel.currentIndex = (viewModel.currentIndex + 1) % viewModel.recommendCoins.count

                    withAnimation(.easeInOut) {
                        selection = viewModel.recommendCoins[viewModel.currentIndex].id
                    }
                }
            }
            .frame(height: 300)
        }
        .padding(.bottom, 40)
    }
}

#Preview {
    RecommendCoinView()
}



