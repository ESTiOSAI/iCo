//
//  CoinListView.swift
//  AIProject
//
//  Created by kangho lee on 7/30/25.
//

import SwiftUI
import AsyncAlgorithms

struct CoinListView: View {
    @Bindable var viewModel: CoinListViewModel
    @State private var visibleCoins: Set<CoinListModel.ID> = []
    @Environment(\.scenePhase) private var scenePhase
    @State var sortCategory: SortCategory? = .volume
    @State var volumeSortOrder: SortOrder = .descending
    @State var nameSortOrder: SortOrder = .none
    
    init(viewModel: CoinListViewModel) {
        self.viewModel = viewModel
    }
    
    var sortedCoins: [CoinListModel] {
        switch sortCategory {
        case .name:
            switch nameSortOrder {
            case .none:
                return viewModel.coins
            case .ascending:
                return viewModel.coins.sorted { $0.name < $1.name }
            case .descending:
                return viewModel.coins.sorted { $0.name > $1.name }
            }
        case .volume:
            switch volumeSortOrder {
            case .none:
                return viewModel.coins
            case .ascending:
                return viewModel.coins.sorted { $0.tradeAmount < $1.tradeAmount }
            case .descending:
                return viewModel.coins.sorted { $0.tradeAmount > $1.tradeAmount }
            }
        case nil:
            return viewModel.coins
        }
    }
   
    
    var body: some View {
        VStack(spacing: 0) {
            List {
                CoinListHeaderView(sortCategory: $sortCategory, nameSortOrder: $nameSortOrder, volumeSortOrder: $volumeSortOrder, action: {
                    
                })
                .fontWeight(.regular)
                .font(.system(size: 11))
                .foregroundStyle(.aiCoLabel)
                .listRowBackground(Color.clear)
                
                ForEach(sortedCoins) { coin in
                    
                    // Geometry가 레이아웃이 바뀌면 rerender를 발동시켜서 소켓 명령어를 다시 실행시켜서 크래쉬 발생
                    GeometryReader { geometry in
                        ZStack {
                            CoinCell(coin: coin)
                            NavigationLink {
                                CoinDetailView(coin: Coin(id: coin.id, koreanName: coin.name))
                            } label: {
                                EmptyView()
                            }.opacity(0)
                        }
                        .onAppear {
                            insertCoin(id: coin.id, proxy: geometry)
                        }
                        .onDisappear {
                            visibleCoins.remove(coin.id)
                        }
                    }
                    .padding(.vertical, 18)
                    .padding(.bottom)
                }
                .listRowBackground(Color.clear)
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .background {
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.aiCoBorderGray, lineWidth: 1)
                    .fill(Color.aiCoBackground)
            }
            .onChange(of: sortCategory) { oldValue, newValue in
                if newValue == .name {
                    volumeSortOrder = .none
                } else {
                    nameSortOrder = .none
                }
            }
        }
        .onChange(of: scenePhase, { _, newValue in
            Task {
                await handleConnection(by: newValue)
            }
        })
        .onChange(of: visibleCoins, { oldValue, newValue in
            Task {
                await viewModel.sendTicket(newValue)
            }
        })
        .onAppear {
            Task {
                await viewModel.connect()
            }
        }
        .onDisappear {
            Task {
                await viewModel.disconnect()
            }
        }
    }
}

extension CoinListView {
    private func insertCoin(id: CoinListModel.ID, proxy: GeometryProxy) {
        guard !visibleCoins.contains(id) else { return }
        let frame = proxy.frame(in: .global)
        let threshold: CGFloat = 80
        
        // cell의 상단 좌표가 프레임 + 임계값 보다 작고
        // cell 하단 좌표가 프레임 - 임계값보다 크면
        // 임계값 기준으로 프레임 넓이 안에 셀이 있으면
        if frame.minY < UIScreen.main.bounds.height + threshold && frame.maxY > -threshold {
            visibleCoins.insert(id)
        }
    }
    private func handleConnection(by phase: ScenePhase) async {
        print(#function, phase)
        switch phase {
        case .background:
            await viewModel.disconnect()
        case .inactive:
            break
        case .active:
            await viewModel.connect()
        @unknown default:
            break
        }
    }
}

#Preview {
    CoinListView(viewModel: .init(tickerService: .init(client: .init()), coinGeckoService: CoinGeckoAPIService(network: .init())))
}
