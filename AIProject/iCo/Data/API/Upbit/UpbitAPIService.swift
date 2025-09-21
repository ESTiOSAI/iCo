//
//  APIService.swift
//  AIProject
//
//  Created by 강대훈 on 7/30/25.
//

import Foundation

/// 업비트 API 관련 서비스를 제공합니다.
final class UpBitAPIService: UpBitApiServiceProtocol {
    private let network: NetworkClient

    init(networkClient: NetworkClient = .init()) {
        self.network = networkClient
    }

    /// 전체 마켓의 KRW(원화) 정보를 가져옵니다.
    /// - Returns: 마켓 정보들의 배열
    func fetchMarkets() async throws -> [CoinDTO] {
        let urlRequest = try UpbitEndpoint.markets.makeURLrequest()
        let coinDTOs: [CoinDTO] = try await network.request(for: urlRequest)
        return coinDTOs.filter { $0.coinID.contains("KRW") }
    }
    
    /// 지정한 인용 화폐 마켓의 모든 코인을 현재 시세를 가져옵니다.
    /// - Parameter currency: 마켓 화폐 (ex. "KRW", "BTC")
    /// - Returns: 해당 카멧의 모든 코인 시세 정보
    func fetchTicker(by currency: String) async throws -> [TickerValue] {
        let urlRequest = try UpbitEndpoint.ticker(currency: currency).makeURLrequest()
        let tickerDTOs: [TickerDTO] = try await network.request(for: urlRequest)
        return tickerDTOs.map { $0.toDomain() }
    }

    /// 지정한 마켓의 체결 이력을 가져옵니다.
    /// - Parameter market: 조회할 마켓 코드 (ex. "KRW-BTC")
    /// - Parameter count: 체결된 이력 개수, 기본값은 1입니다.
    /// - Returns: 해당 마켓의 최근 체결 정보
    func fetchTicks(id market: String, count: Int = 1) async throws -> [RecentTradeDTO] {
        let urlRequest = try UpbitEndpoint.ticks(id: market, count: count).makeURLrequest()
        let recentTradeDTOs: [RecentTradeDTO] = try await network.request(for: urlRequest)
        return recentTradeDTOs
    }
    
    /// 지정한 마켓의 현재 시세 정보를 가져옵니다.
    /// - Parameter market: 조회할 마켓 코드 (ex. "KRW-BTC")
    /// - Returns: 해당 마켓의 시세 정보
    func fetchQuotes(id market: String) async throws -> [TickerDTO] {
        let urlRequest = try UpbitEndpoint.quotes(id: market).makeURLrequest()
        let tickerDTOs: [TickerDTO] = try await network.request(for: urlRequest)
        return tickerDTOs
    }

    /// 지정한 코인(마켓)의 1분봉 캔들 데이터를 가져옵니다.
    /// - Parameters:
    ///   - market: 조회할 마켓 코드 (ex. "RKW-BTC")
    ///   - count: 가져올 캔들 데이터 개수, 기본값은 1입니다.
    /// - Returns: 해당 코인(마켓)의 1분 단위의 캔들 정보
    func fetchCandles(id market: String, count: Int = 1, to: Date? = nil) async throws -> [MinuteCandleDTO] {
        let urlRequest = try UpbitEndpoint.candles(id: market, count: count, to: to).makeURLrequest()
        let minuteCandleDTOs: [MinuteCandleDTO] = try await network.request(for: urlRequest)
        return minuteCandleDTOs
    }
}
