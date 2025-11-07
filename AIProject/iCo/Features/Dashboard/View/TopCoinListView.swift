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
                    .foregroundStyle(.iCoLabel)
            }
            .font(.ico18B)

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
            .padding(.horizontal, -4)
            .padding(.bottom, 4)
            
            if viewModel.isLoading {
                DefaultProgressView(status: .loading, message: "시세 불러오는중")
            } else {
                TopCoinListSection(viewModel: viewModel)
            }
        }
        .padding(22)
        .background(.iCoBackground)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .strokeBorder(.defaultGradient, lineWidth: 0.5)
        )
        .background(
            GeometryReader { geo in
                Color.clear
                    .preference(key: HeightPreferenceKey.self,
                                value: geo.size.height)
            }
        )
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
                            .font(.ico15B)
                            .foregroundColor(.iCoAccent)
                            .padding(.trailing, 16)
                        
                        CoinView(symbol: coin.coinSymbol, size: 40)
                            .padding(.trailing, 8)

                        VStack(alignment: .leading, spacing: 4) {
                            Text(viewModel.koreanName(for: coin.id))
                                .font(.ico16Sb)
                                .lineLimit(1)
                                .foregroundStyle(.iCoLabel)
                            if viewModel.selectedSegment == .volume {
                                Text(coin.formatedVolume)
                                    .font(.ico14)
                                    .foregroundColor(.iCoLabelSecondary)
                            } else {
                                Text(coin.formatedRate)
                                    .font(.ico14)
                                    .foregroundColor(
                                        coin.change == .rise ? .iCoPositive :
                                        (coin.change == .fall ? .iCoNegative : .iCoNeutral)
                                    )
                            }
                        }
                        .padding(.trailing, 8)

                        Spacer()

                        if let values = viewModel.candles[coin.id] {
                            LineChartView(
                                values: values,
                                lineColor: coin.change == .fall ? .iCoNegative : .iCoPositive
                            )
                            .frame(width: 80, height: 40)
                        } else {
                            ProgressView()
                                .frame(width: 80, height: 40)
                        }
                    }
                    .padding(.bottom, index != viewModel.topCoins.count - 1 ? 14 : 0)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    TopCoinListView()
        .environmentObject(ThemeManager())
        .environment(CoinStore(coinService: DefaultCoinService(network: NetworkClient())))
        .padding()
}
