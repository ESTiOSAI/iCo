//
//  TopCoinListViewModel.swift
//  iCo
//
//  Created by 백현진 on 10/28/25.
//

import SwiftUI

@MainActor
final class TopCoinListViewModel: ObservableObject {
    private let api = UpBitAPIService()
    
    @Published var tickers: [TickerValue] = []
    @Published var coins: [CoinDTO] = []
    @Published var candles: [String: [Double]] = [:]
    @Published var isLoading = false
    @Published var selectedSegment: SegmentType = .volume
    
    enum SegmentType: String, CaseIterable, Identifiable {
        case volume = "거래대금 Top5"
        case rate = "상승률 Top5"
        var id: String { rawValue }
    }
    
    func fetchData() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let coins = try await api.fetchMarkets()
            self.coins = coins
            
            let tickers = try await api.fetchTicker(by: "KRW")
            self.tickers = tickers
            
            let topMarkets = tickers
                .sorted { $0.volume > $1.volume }
                .prefix(10)
                .map { $0.id }
            
            for id in topMarkets {
                let candles = try await api.fetchCandles(id: id, count: 10)
                self.candles[id] = candles.map { $0.tradePrice }.reversed()
            }
        } catch {
            print("Fetch Error:", error)
        }
    }
    
    var topCoins: [TickerValue] {
        switch selectedSegment {
        case .volume:
            return Array(tickers.sorted { $0.volume > $1.volume }.prefix(5))
        case .rate:
            return Array(tickers.sorted { $0.signedRate > $1.signedRate }.prefix(5))
        }
    }
    
    func koreanName(for id: String) -> String {
        coins.first(where: { $0.coinID == id })?.koreanName ?? id
    }
}
