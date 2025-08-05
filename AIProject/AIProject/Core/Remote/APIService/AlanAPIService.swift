//
//  AlanAPIService.swift
//  AIProject
//
//  Created by 강대훈 on 7/30/25.
//

import Foundation

/// 앨런 API 관련 서비스를 제공합니다.
final class AlanAPIService {
    private let network: NetworkClient
    private let endpoint: String = "https://kdt-api-function.azurewebsites.net/api/v1/question"

    init(networkClient: NetworkClient = .init()) {
        self.network = networkClient
    }

    /// 입력한 질문 또는 문장에 대한 응답을 가져옵니다.
    /// - Parameter content: 질문 또는 분석할 문장
    /// - Returns: 수신한 응답 데이터
    func fetchAnswer(content: String, action: AlanAction) async throws -> AlanResponseDTO {
        guard let clientID = switchClientID(for: action) else { throw NetworkError.invalidAPIKey }

        let urlString = "\(endpoint)?content=\(content)&client_id=\(clientID)"
        guard let url = URL(string: urlString) else { throw NetworkError.invalidURL }
        let alanResponseDTO: AlanResponseDTO = try await network.request(url: url)

        return alanResponseDTO
    }
}

extension AlanAPIService {
    /// Alan이 수행할 작업에 따라 ClientID를 전환합니다.
    private func switchClientID(for action: AlanAction) -> String? {
        switch action {
        case .coinRecomendation:
            return Bundle.main.infoDictionary?["ALAN_API_KEY_COIN_RECOMENDATION"] as? String
        case .coinReportGeneration:
            return Bundle.main.infoDictionary?["ALAN_API_KEY_COIN_REPORT_GENERATION"] as? String
        case .coinIDExtraction:
            return Bundle.main.infoDictionary?["ALAN_API_KEY_COIN_ID_EXTRACTION"] as? String
        }
    }
    
    /// "\(coin.koreanName)" 개요를 JSON 형식으로 가져옵니다.
    func fetchOverview(for coin: Coin) async throws -> CoinOverviewDTO {
        // 캐시된 응답이 있으면 바로 반환
        let cacheURL = URL(string: "https://api.example.com/coins/\(coin.id)/overview")!
        let request = URLRequest(url: cacheURL, cachePolicy: .returnCacheDataElseLoad)
        if let cachedResponse = URLCache.shared.cachedResponse(for: request) {
            return try JSONDecoder().decode(CoinOverviewDTO.self, from: cachedResponse.data)
        }

        let content = """
        struct CoinOverviewDTO: Codable {
            let symbol: String 
            let websiteURL: String?
            let launchDate: String
            let description: String
        }
        
        \"\(coin.koreanName)\" 개요를 위 JSON 형식으로 작성 (마크다운 금지, 실제 뉴스 링크 전달)
        """
        let answer = try await fetchAnswer(content: content, action: .coinReportGeneration)
        guard let jsonData = answer.content.extractedJSON.data(using: .utf8) else {
            throw DecodingError.dataCorrupted(
                DecodingError.Context(
                    codingPath: [],
                    debugDescription: "extractedJSON 문자열을 UTF-8 데이터로 변환하는 데 실패했습니다."
                )
            )
        }
        
        do {
            let dto = try JSONDecoder().decode(CoinOverviewDTO.self, from: jsonData)
            let response = URLResponse(
                url: cacheURL,
                mimeType: "application/json",
                expectedContentLength: jsonData.count,
                textEncodingName: "utf-8"
            )
            let cacheEntry = CachedURLResponse(response: response, data: jsonData)
            URLCache.shared.storeCachedResponse(cacheEntry, for: request)
            return dto
        } catch {
            throw error
        }
    }

    /// 최근 24시간 뉴스 기반 시장 분위기와 기사 목록을 JSON 형식으로 가져옵니다.
    func fetchTodayNews(for coin: Coin) async throws -> CoinTodayNewsDTO {
        let content = """
        struct CoinTodayNewsDTO: Codable {
            let summaryOfTodaysMarketSentiment: String
            let articles: [CoinArticleDTO]
        }

        struct CoinArticleDTO: Codable {
            let title: String
            let summary: String
            let url: String
        }

        1. 현재 국내 시간을 기준으로 최근 24시간 뉴스 기반
        2. 뉴스 전반을 분석해 시장 분위기를 요약

        위 조건에 따라 \"\(coin.koreanName)\"에 대한 내용을 위 JSON 형식으로 작성 (마크다운 금지)
        """
        let answer = try await fetchAnswer(content: content, action: .coinReportGeneration)
        guard let jsonData = answer.content.extractedJSON.data(using: .utf8) else {
            throw DecodingError.dataCorrupted(
                DecodingError.Context(
                    codingPath: [],
                    debugDescription: "extractedJSON 문자열을 UTF-8 데이터로 변환하는 데 실패했습니다."
                )
            )
        }
        
        do {
            return try JSONDecoder().decode(CoinTodayNewsDTO.self, from: jsonData)
        } catch {
            throw error
        }
    }

    /// 일주일간의 가격 추이 및 거래량 변화 정보를 JSON 형식으로 가져옵니다.
    func fetchWeeklyTrends(for coin: Coin) async throws -> CoinWeeklyDTO {
        let content = """
        struct CoinWeeklyDTO: Codable {
            let priceTrend: String
            let volumeChange: String
            let reason: String
        }

        1. 현재 국내 시간을 기준으로 일주일 동안의 정보 사용

        위 조건에 따라 \"\(coin.koreanName)\"에 대한 내용을 위 JSON 형식으로 작성 (마크다운 금지)
        """
        let answer = try await fetchAnswer(content: content, action: .coinReportGeneration)
        guard let jsonData = answer.content.extractedJSON.data(using: .utf8) else {
            throw DecodingError.dataCorrupted(
                DecodingError.Context(
                    codingPath: [],
                    debugDescription: "extractedJSON 문자열을 UTF-8 데이터로 변환하는 데 실패했습니다."
                )
            )
        }
        do {
            return try JSONDecoder().decode(CoinWeeklyDTO.self, from: jsonData)
        } catch {
            throw error
        }
    }
}
