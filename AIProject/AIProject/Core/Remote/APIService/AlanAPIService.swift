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
    
    /// 지정된 프롬프트와 작업 타입에 따라 응답을 받아 디코딩된 DTO를 반환합니다.
    ///
    /// - Parameters:
    ///   - prompt: 요청을 생성하는 프롬프트
    ///   - action: 요청 목적에 따른 작업 타입
    /// - Returns: 디코딩된 DTO 객체
    private func fetchDTO<T: Decodable>(prompt: Prompt, action: AlanAction) async throws -> T {
        let answer = try await fetchAnswer(content: prompt.content, action: action)
        
        guard let jsonData = answer.content.extractedJSON.data(using: .utf8) else {
            throw DecodingError.dataCorrupted(
                DecodingError.Context(
                    codingPath: [],
                    debugDescription: "extractedJSON 문자열을 UTF-8 데이터로 변환 실패"
                )
            )
        }
        
        return try JSONDecoder().decode(T.self, from: jsonData)
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
    
    /// 지정된 코인에 대한 개요 정보를 JSON으로 가져옵니다.
    ///
    /// 캐시가 있다면 캐시된 데이터를 먼저 반환하고, 없으면 새로 요청 후 캐싱합니다.
    /// - Parameter coin: 개요 정보를 요청할 코인
    /// - Returns: 디코딩된 개요 DTO
    func fetchOverview(for coin: Coin) async throws -> CoinOverviewDTO {
        // 캐시된 응답이 있으면 바로 반환
        let cacheURL = URL(string: "https://api.example.com/coins/\(coin.id)/overview")!
        let request = URLRequest(url: cacheURL, cachePolicy: .returnCacheDataElseLoad)
        if let cachedResponse = URLCache.shared.cachedResponse(for: request) {
            return try JSONDecoder().decode(CoinOverviewDTO.self, from: cachedResponse.data)
        }
        
        let prompt = Prompt.generateOverView(coinKName: coin.koreanName)
        let dto: CoinOverviewDTO = try await fetchDTO(prompt: prompt, action: .coinReportGeneration)
        let jsonData = try JSONEncoder().encode(dto)
        
        let response = URLResponse(
            url: cacheURL,
            mimeType: "application/json",
            expectedContentLength: jsonData.count,
            textEncodingName: "utf-8"
        )
        let cacheEntry = CachedURLResponse(response: response, data: jsonData)
        URLCache.shared.storeCachedResponse(cacheEntry, for: request)
        
        return dto
    }
    
    /// 주어진 코인에 대해 주간 트렌드 데이터를 가져옵니다.
    ///
    /// - Parameter coin: 대상 코인
    /// - Returns: 디코딩된 DTO
    func fetchWeeklyTrends(for coin: Coin) async throws -> CoinWeeklyDTO {
        let prompt = Prompt.generateWeeklyTrends(coinKName: coin.koreanName)
        return try await fetchDTO(prompt: prompt, action: .coinReportGeneration)
    }
    
    /// 주어진 코인에 대해 24시간 뉴스 및 시장 분위기 데이터를 가져옵니다.
    ///
    /// - Parameter coin: 대상 코인
    /// - Returns: 디코딩된 DTO
    func fetchTodayNews(for coin: Coin) async throws -> CoinTodayNewsDTO {
        let prompt = Prompt.generateTodayNews(coinKName: coin.koreanName)
        return try await fetchDTO(prompt: prompt, action: .coinReportGeneration)
    }
    
    /// 주어진 코인에 대해 2시간 단위 전체 시장 요약 데이터를 가져옵니다.
    ///
    /// - Parameter coin: 대상 코인
    /// - Returns: 디코딩된 DTO
    func fetchTodayInsight() async throws -> TodayInsightDTO {
        let prompt = Prompt.generateTodayInsight
        return try await fetchDTO(prompt: prompt, action: .coinReportGeneration)
    }
    
    /// 주어진 코인에 대해 커뮤니티 기반 인사이트 데이터를 가져옵니다.
    ///
    /// - Parameter coin: 대상 코인
    /// - Returns: 디코딩된 DTO
    func fetchCommunityInsight(from post: String) async throws -> CommunityInsightDTO {
        let prompt = Prompt.generateCommunityInsight(redditPost: post)
        return try await fetchDTO(prompt: prompt, action: .coinReportGeneration)
    }
}
