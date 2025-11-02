//
//  TopCoinListView.swift
//  iCo
//
//  Created by 백현진 on 10/28/25.
//

import SwiftUI

struct TopCoinListView: View {
    @StateObject private var viewModel = TopCoinListViewModel()
    @State private var selectedTab = 0
    
    var body: some View {
        VStack(alignment: .leading ,spacing: 16) {
            HStack {
                Image(systemName: "bitcoinsign.bank.building")
                    .foregroundStyle(.iCoAccent)
                
                Text("주목할 만한 코인 TOP5")
            }
            .font(.ico16B)
            .padding(.horizontal, 22)
            .padding(.top, 20)

            SegmentedControlView(
                selection: Binding(
                    get: {
                        viewModel.selectedSegment.index
                    },
                    set: { newIndex in
                        viewModel.selectedSegment = TopCoinListViewModel.SegmentType.allCases[newIndex]
                    }
                ),
                tabTitles: TopCoinListViewModel.SegmentType.allCases.map { $0.rawValue },
                width: .infinity
            )
            .padding(.horizontal)
            
            if viewModel.isLoading {
                DefaultProgressView(status: .loading, message: "시세 불러오는중")
            } else {
                TopCoinListSection(viewModel: viewModel)
            }
        }
        .background(.iCoBackground)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .strokeBorder(.defaultGradient, lineWidth: 0.5)
        )
        .padding(.horizontal, 16)
        .onAppear {
            Task {
                await viewModel.fetchData()
            }
        }
        .onDisappear {
            viewModel.cancelFetch()
        }
    }
}

struct TopCoinListSection: View {
    @ObservedObject var viewModel: TopCoinListViewModel
    @State private var showNewBadge = false
    @Environment(CoinStore.self) var coinStore

    var body: some View {
        VStack {
            ForEach(Array(viewModel.topCoins.enumerated()), id: \.element.id) { index, coin in
                NavigationLink {
                    if let meta = coinStore.coins[coin.id] {
                        VStack(spacing: 0) {
                            HeaderView(
                                heading: meta.koreanName,
                                coinSymbol: meta.coinSymbol,
                                showBackButton: true,
                                showNewBadge: showNewBadge
                            )
                            .toolbar(.hidden, for: .navigationBar)
                            
                            CoinDetailView(coin: meta) { isNew in
                                showNewBadge = isNew
                            }
                            .id(coin.id)
                        }
                    }
                } label: {
                    HStack {
                        Text("\(index + 1)")
                            .font(.ico14B)
                            .foregroundColor(.iCoAccent)
                            .padding(.trailing, 16)

                        CachedAsyncImage(resource: .symbol(coin.coinSymbol)) {
                            Text(String(coin.coinSymbol.prefix(1)))
                                .font(.ico15Sb)
                                .foregroundStyle(.iCoAccent)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .background(.iCoBackgroundAccent)
                                .overlay(
                                    Circle().strokeBorder(.defaultGradient, lineWidth: 0.5)
                                )
                        }
                        .frame(width: 40, height: 40)
                        .clipShape(Circle())
                        .padding(.trailing, 8)

                        VStack(alignment: .leading, spacing: 8) {
                            Text(viewModel.koreanName(for: coin.id))
                                .font(.ico15)
                            if viewModel.selectedSegment == .volume {
                                Text(coin.formatedVolume)
                                    .font(.ico12)
                                    .foregroundColor(.iCoLabelSecondary)
                            } else {
                                Text(coin.formatedRate)
                                    .font(.ico12)
                                    .foregroundColor(
                                        coin.change == .rise ? .iCoPositive :
                                        (coin.change == .fall ? .iCoNegative : .iCoNeutral)
                                    )
                            }
                        }

                        Spacer()

                        if let values = viewModel.candles[coin.id] {
                            LineChartView(
                                values: values,
                                lineColor: coin.change == .fall ? .iCoNegative : .iCoPositive
                            )
                            .frame(width: 100, height: 40)
                        } else {
                            ProgressView()
                                .frame(width: 100, height: 40)
                        }
                    }
                    .padding(.vertical, 16)
                    .padding(.horizontal, 22)
                }
                .buttonStyle(.plain)
            }
        }
    }
}

#Preview {
    TopCoinListView()
}
