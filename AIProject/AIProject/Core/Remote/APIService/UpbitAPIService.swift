//
//  APIService.swift
//  AIProject
//
//  Created by 강대훈 on 7/30/25.
//

import Foundation

/// 업비트 API 관련 서비스를 제공합니다.
final class UpBitAPIService {
    private let network: NetworkClient
    private let endpoint: String = "https://api.upbit.com/v1"

    init(networkClient: NetworkClient = .init()) {
        self.network = networkClient
    }

    /// 전체 마켓의 정보를 가져옵니다.
    /// - Returns: 마켓 정보들의 배열
    func fetchMarkets() async throws -> [MarketDTO] {
        let urlString = "\(endpoint)/market/all"
        guard let url = URL(string: urlString) else { throw NetworkError.invalidURL }
        let marketDTOs: [MarketDTO] = try await network.request(url: url)

		return marketDTOs
    }

    /// 지정한 마켓의 체결 이력을 가져옵니다.
    /// - Parameter market: 조회할 마켓 코드 (ex. "KRW-BTC")
    /// - Parameter count: 체결된 이력 개수, 기본값은 1입니다.
    /// - Returns: 해당 마켓의 최근 체결 정보
    func fetchTicks(id market: String, count: Int = 1) async throws -> [TradeTickDTO] {
        let urlString = "\(endpoint)/trades/ticks?market=\(market)&count=\(count)"
        guard let url = URL(string: urlString) else { throw NetworkError.invalidURL }
        let tradeTickDTOs: [TradeTickDTO] = try await network.request(url: url)

        return tradeTickDTOs
    }
    
    /// 지정한 마켓의 현재 시세 정보를 가져옵니다.
    /// - Parameter market: 조회할 마켓 코드 (ex. "KRW-BTC")
    /// - Returns: 해당 마켓의 시세 정보
    func fetchQuotes(id market: String) async throws -> [CoinQuoteDTO] {
        let urlString = "\(endpoint)/ticker?markets=\(market)"
        guard let url = URL(string: urlString) else { throw NetworkError.invalidURL }
        let quoteDTOs: [CoinQuoteDTO] = try await network.request(url: url)

        return quoteDTOs
    }
}
