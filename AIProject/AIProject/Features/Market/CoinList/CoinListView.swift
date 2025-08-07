//
//  CoinListView.swift
//  AIProject
//
//  Created by kangho lee on 7/30/25.
//

import SwiftUI
import AsyncAlgorithms

struct CoinListView: View {
    private let viewModel = CoinListViewModel(socket: .init())
    @State private var visibleCoins: Set<CoinListModel.ID> = []
    @Environment(\.scenePhase) private var scenePhase
    
    var body: some View {
        NavigationStack {
            List {
                CoinListHeaderView()
                    .fontWeight(.regular)
                    .font(.system(size: 11))
                    .foregroundStyle(.aiCoLabel)
                
                ForEach(viewModel.coins) { coin in
                    
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
                }
            }
        }
        .onChange(of: scenePhase, { _, newValue in
            Task {
                await handleConnection(by: newValue)
            }
        })
        .onChange(of: visibleCoins, { oldValue, newValue in
            guard visibleCoins.count > 5 else { return }
            
            Task {
                await viewModel.sendTIcket(newValue)
            }
        })
        .onAppear {
            Task {
                await viewModel.connect()
            }
        }
        .onDisappear {
            viewModel.disconnect()
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
            viewModel.disconnect()
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
    CoinListView()
}
