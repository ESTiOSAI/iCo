//
//  APIService.swift
//  AIProject
//
//  Created by 강대훈 on 7/30/25.
//

import Foundation

final class UpBitAPIService {
    private let network: NetworkClient
    private let endpoint: String = "https://api.upbit.com/v1"

    init(networkClient: NetworkClient = .init()) {
        self.network = networkClient
    }

    func fetchMarkets() async throws -> [MarketDTO] {
        let urlString = "\(endpoint)/market/all"
        let marketDTOs: [MarketDTO] = try await network.request(url: URL(string: urlString)!)

		return marketDTOs
    }

    func fetchTicks(market: String) async throws -> [TradeTickDTO] {
        let urlString = "\(endpoint)/trades/ticks?market=\(market)"
        let tradeTickDTOs: [TradeTickDTO] = try await network.request(url: URL(string: urlString)!)

        return tradeTickDTOs
    }

    func fetchQuotes(market: String) async throws -> [CoinQuoteDTO] {
        let urlString = "\(endpoint)/ticker?markets=\(market)"
        let quoteDTOs: [CoinQuoteDTO] = try await network.request(url: URL(string: urlString)!)

        return quoteDTOs
    }
}
