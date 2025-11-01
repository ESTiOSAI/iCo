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
    
    private var fetchTask: Task<Void, Never>?
    
    enum SegmentType: String, CaseIterable, Identifiable {
        case volume = "거래대금 Top5"
        case rate = "상승률 Top5"
        var id: String { rawValue }
        
        var index: Int {
            Self.allCases.firstIndex(of: self) ?? 0
        }
    }
    
    func fetchData() async {
        if fetchTask != nil { return }
        
        fetchTask = Task {
            isLoading = true
            defer {
                isLoading = false
                fetchTask = nil
            }
            
            do {
                guard !Task.isCancelled else { return }
                let coins = try await api.fetchMarkets()
                self.coins = coins
                
                let tickers = try await api.fetchTicker(by: "KRW")
                self.tickers = tickers
                
                let topVolumeIDs = tickers
                    .sorted { $0.volume > $1.volume }
                    .prefix(5)
                    .map { $0.id }
                
                let topRateIDs = tickers
                    .sorted { $0.signedRate > $1.signedRate }
                    .prefix(5)
                    .map { $0.id }
                
                let targetIDs = Array(Set(topVolumeIDs + topRateIDs))
                
                guard !Task.isCancelled else { return }
                
                await withTaskGroup(of: Void.self) { group in
                    for id in targetIDs {
                        group.addTask {
                            do {
                                let candleData = try await self.api.fetchCandles(id: id, count: 10)
                                await MainActor.run {
                                    self.candles[id] = candleData.map { $0.tradePrice }.reversed()
                                }
                            } catch {
                                print("Candle fetch failed for \(id):", error)
                            }
                        }
                    }
                }
            } catch {
                print("Fetch Error:", error)
            }
        }
        
        await fetchTask?.value
    }
    
    func cancelFetch() {
        fetchTask?.cancel()
        fetchTask = nil
        isLoading = false
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
