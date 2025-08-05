//
//  CoinListView.swift
//  AIProject
//
//  Created by kangho lee on 7/30/25.
//

import SwiftUI

struct CoinListView: View {
    let viewModel = CoinListViewModel(socket: .init())
    @State private var visibleCoins: Set<CoinListModel.ID> = []
    
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
                            }
                        }
                        .onAppear {
                            guard !visibleCoins.contains(coin.id) else { return }
                            let frame = geometry.frame(in: .global)
                            cellOnAppear(frame, id: coin.id)
                        }
                        .onDisappear {
                            visibleCoins.remove(coin.id)
                            viewModel.unsubscribe(visibleCoins)
                        }
                    }
                }
            }
        }
        .task {
            await viewModel.fetchInitial()
        }
        .onChange(of: visibleCoins, { oldValue, newValue in
            print("add: \(newValue.subtracting(oldValue))\nremove:\(oldValue.subtracting(newValue))")
            print("count: \(newValue.count)")
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
    private func cellOnAppear(_ frame: CGRect, id: CoinListModel.ID) {
        let threshold: CGFloat = 80
        
        // cell의 상단 좌표가 프레임 + 임계값 보다 작고
        // cell 하단 좌표가 프레임 - 임계값보다 크면
        // 임계값 기준으로 프레임 넓이 안에 셀이 있으면
        if frame.minY < UIScreen.main.bounds.height + threshold && frame.maxY > -threshold {
            
            visibleCoins.insert(id)
            viewModel.subscribe(visibleCoins)
        }
    }
}

fileprivate struct CoinListHeaderView: View {
    var body: some View {
        HStack(spacing: 60) {
            HStack {
                Text("한글명")
                Image(systemName: "arrow.up.arrow.down")
            }
            
            HStack {
                Text("현재가")
                    .frame(maxWidth: 80, alignment: .trailing)
                
                Text("전일대비")
                    .frame(maxWidth: 40, alignment: .trailing)
            }
            
            Text("거래대금")
        }
    }
}

fileprivate struct CoinCell: View {
    let coin: CoinListModel
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack(spacing: 8) {
                VStack(alignment: .leading) {
                    Text(coin.name)
                        .font(.system(size: 14))
                    
                    Text(coin.coinName)
                        .font(.system(size: 12))
                        .font(.callout)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: 100, alignment: .leading)
                
                Text(coin.currentPrice, format: .number)
                    .font(.system(size: 12))
                    .foregroundStyle(.red)
                    .frame(maxWidth: 75, alignment: .trailing)
                
                Text(coin.changePrice, format: .percent.precision(.fractionLength(2)))
                    .font(.system(size: 12))
                    .foregroundStyle(.red)
                    .frame(maxWidth: 40, alignment: .trailing)
                
                HStack(spacing: 0) {
                    Text(coin.tradeAmount.formattedCurrency())
                        .font(.system(size: 12))
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
            }
            .fontWeight(.medium)
            .foregroundStyle(.aiCoLabel)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

#Preview {
    CoinListView()
}
