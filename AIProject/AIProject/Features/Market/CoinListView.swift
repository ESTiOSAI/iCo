//
//  CoinListView.swift
//  AIProject
//
//  Created by kangho lee on 7/30/25.
//

import SwiftUI

@Observable
class CoinListViewModel {
    private let socket: WebSocketClient
    private let upbitService: UpBitAPIService
    
    var coins: [CoinListModel] = []
    
    init(socket: WebSocketClient) {
        self.socket = socket
        self.upbitService = UpBitAPIService()
    }
    
    func connect() async {
        try? await socket.connect()
    }
    
    func disconnect() {
        socket.disconnect()
    }
    
    func fetchTickerbyMarket() async -> [String] {
        []
    }
    
    func fetchInitial() async {
        self.coins = await fetchMarketCoinData()
    }
    
    private func fetchMarketCoinData() async -> [CoinListModel] {
        async let coins = (try? await upbitService.fetchMarkets()) ?? []
        async let tickers = (try? await upbitService.fetchTicker(by: "KRW")) ?? []
        
        let result = await coins.reduce(into: [String: (korean: String, english: String)]()){ acc, coins in
                    
            acc[coins.coinID] = (coins.koreanName, coins.englishName)
        }
        
        return await tickers.compactMap { ticker in
            CoinListModel(
                coinID: ticker.coinID,
                image: "",
                name: result[ticker.coinID]?.korean ?? "없음",
                currentPrice: ticker.tradePrice,
                changePrice: ticker.changeRate,
                tradeAmount: ticker.accTradePrice
            )
        }
    }
}

struct CoinListView: View {
    
    let viewModel = CoinListViewModel(socket: .init())
    
    var body: some View {
        VStack {
            
            List {
                HStack(spacing: 60) {
                    HStack {
                        Text("한글명")
                        Image(systemName: "arrow.up.arrow.down")
                    }
                    
                    HStack {
                        Text("현재가")
                        
                        Text("전일대비")
                    }
                    
                    Text("거래대금")
                }
                .fontWeight(.regular)
                .font(.system(size: 11))
                .foregroundStyle(.aiCoLabel)
                
                ForEach(viewModel.coins) { coin in
//                    NavigationLink {
//                        CoinDetailView(coin: Coin(id: coin.coinID, koreanName: coin.name))
//                    } label: {
                        VStack(alignment: .leading) {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(coin.name)
                                        .font(.system(size: 14))
                                    
                                    Text(coin.coinName)
                                        .font(.system(size: 12))
                                        .font(.callout)
                                        .foregroundStyle(.secondary)
                                }
                                
                                Text(coin.currentPrice, format: .number)
                                    .font(.system(size: 14))
                                    .foregroundStyle(.red)
                                
                                Text(coin.changePrice, format: .percent.precision(.fractionLength(2)))
                                    .font(.system(size: 14))
                                    .foregroundStyle(.red)
                                
                                Text(162140000, format: .number)
                                    .font(.system(size: 12))
                                Text("원")
                                    .font(.system(size: 12))
                            }
                            .fontWeight(.medium)
                            .foregroundStyle(.aiCoLabel)
                            .frame(maxWidth: .infinity)
//                        }
                    }
                }
            }
            .task {
                await viewModel.connect()
                await viewModel.fetchInitial()
            }
            .onDisappear {
                viewModel.disconnect()
            }
        }
    }
}

#Preview {
    CoinListView()
}
