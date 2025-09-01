//
//  AlanAPIService.swift
//  AIProject
//
//  Created by 강대훈 on 7/30/25.
//

import Foundation
import SwiftUI

/// 앨런 API 관련 서비스를 제공합니다.
final class AlanAPIService: AlanAPIServiceProtocol {
    @AppStorage(AppStorageKey.cacheBriefTodayTimestamp) private var cacheBriefTodayTimestamp: String = ""
    @AppStorage(AppStorageKey.cacheBriefCommunityTimestamp) private var cacheBriefCommunityTimestamp: String = ""

    private let network: NetworkClient
    private let endpoint: String = "https://kdt-api-function.azurewebsites.net/api/v1/question"
    
    init(networkClient: NetworkClient = .init()) {
        self.network = networkClient
    }
    
    /// 입력한 질문 또는 문장에 대한 응답을 가져옵니다.
    ///
    /// - Parameter content: 질문 또는 분석할 문장
    /// - Returns: 수신한 응답 데이터
    func fetchAnswer(content: String, action: AlanAction) async throws -> AlanResponseDTO {
        guard let clientID = switchClientID(for: action), !clientID.isEmpty else { throw NetworkError.invalidAPIKey }
        
        let urlString = "\(endpoint)?content=\(content)&client_id=\(clientID)"
        guard let url = URL(string: urlString) else { throw NetworkError.invalidURL }
        let alanResponseDTO: AlanResponseDTO = try await network.request(url: url)
        
        return alanResponseDTO
    }
    
    /// 지정된 프롬프트와 작업 타입에 따라 JSON String 응답을 받아 디코딩된 DTO를 반환합니다.
    ///
    /// - Parameters:
    ///   - prompt: 요청을 생성하는 프롬프트
    ///   - action: 요청 목적에 따른 작업 타입
    /// - Returns: 디코딩된 DTO 객체
    private func fetchDTO<T: Decodable>(prompt: Prompt, action: AlanAction) async throws -> T {
        let answer = try await fetchAnswer(content: prompt.content, action: action)
        
        guard let jsonData = answer.content.extractedJSON.data(using: .utf8) else {
            throw NetworkError.encodingError
        }
        
        do {
            return try JSONDecoder().decode(T.self, from: jsonData)
        } catch let decodingError as DecodingError {
            throw NetworkError.decodingError(decodingError)
        }
    }
}

extension AlanAPIService {
    /// Alan이 수행할 작업에 따라 ClientID를 전환합니다.
    private func switchClientID(for action: AlanAction) -> String? {
        switch action {
        case .coinRecomendation:
            return Bundle.main.infoDictionary?["ALAN_API_KEY_COIN_RECOMENDATION"] as? String
        case .dashboardBriefingGeneration:
            return Bundle.main.infoDictionary?["ALAN_API_KEY_AI_BRIEFING_GENERATION"] as? String
        case .coinReportGeneration:
            return Bundle.main.infoDictionary?["ALAN_API_KEY_COIN_REPORT_GENERATION"] as? String
        case .coinIDExtraction:
            return Bundle.main.infoDictionary?["ALAN_API_KEY_COIN_ID_EXTRACTION"] as? String
        case .bookmarkSuggestion:
            return Bundle.main.infoDictionary?["ALAN_API_KEY_BOOKMARK_SUGGESTION"] as? String
        }
    }
    
    /// 사용자의 투자 성향과 관심 코인을 기반으로 추천 코인 목록을 요청합니다.
    ///
    /// 캐시가 있다면 캐시된 데이터를 먼저 반환하고, 없으면 새로 요청 후 캐싱합니다.
    /// - Parameters:
    ///   - preference: 사용자의 투자 성향을 나타내는 문자열입니다.
    ///     예: `"초보자"`, `"중수"`, `"고수"`
    ///   - bookmarkCoins: 사용자가 북마크한 코인 이름을 쉼표로 구분한 문자열입니다.
    ///     예: `"비트코인,이더리움"`
    func fetchRecommendCoins(preference: String, bookmarkCoins: String, ignoreCache: Bool) async throws -> [RecommendCoinDTO] {
        let interval: TimeInterval = 60 * 60
        var dto = [RecommendCoinDTO]()
        
        // timestamp, 투자 성향, 북마크를 가지고 URL을 생성해주는 헬퍼 함수
        lazy var cacheURL: URL? = {
            let currentTimestamp = Date().numbersOnly
            let cacheKey = "\(currentTimestamp)_\(preference)_\(bookmarkCoins)"
            return URL(string: "https://cache.local/coinRecommendation/\(cacheKey)")
        }()
        
        if !ignoreCache {
            // UserDefaults에 타임스탬프와 캐시 URL이 있다면
            if let lastTimestamp = UserDefaults.standard.value(forKey: AppStorageKey.cacheCoinRecomTimestamp) as? Date,
               let lastCacheURLString = UserDefaults.standard.value(forKey: AppStorageKey.cacheCoinRecomURL) as? String {
                let now = Date.now
                
                // 타임스탬프 비교하기
                // 기준 시간보다 작을 경우에는 기존 URL 사용하기
                if now.timeIntervalSince(lastTimestamp) <= interval {
                    cacheURL = URL(string: lastCacheURLString)
                }
            }
        }
        
        guard let cacheURL else { return [] }
        
        let request = URLRequest(url: cacheURL, cachePolicy: .returnCacheDataElseLoad)
        
        // 기존 캐시 확인하기
        if !ignoreCache && URLCache.shared.cachedResponse(for: request) != nil {
            guard let cachedResponse = URLCache.shared.cachedResponse(for: request) else { return [] }
            dto = try JSONDecoder().decode([RecommendCoinDTO].self, from: cachedResponse.data)
        } else {
            let prompt = Prompt.recommendCoin(preference: preference, bookmark: bookmarkCoins)
            
            dto = try await fetchDTO(prompt: prompt, action: .coinRecomendation)
            
            // 이전 캐시가 남아있다면 삭제하기
            if let lastCacheURLString = UserDefaults.standard.value(forKey: AppStorageKey.cacheCoinRecomURL) as? String,
               let lastCacheURL = URL(string: lastCacheURLString) {
                URLCache.shared.removeCachedResponse(for: URLRequest(url: lastCacheURL))
            }
            
            // 응답 캐싱하고 UserDefaults에 저장하기
            do {
                // dto를 JSON 데이터로 인코딩하기
                let jsonData = try JSONEncoder().encode(dto)
                
                let response = URLResponse(
                    url: cacheURL,
                    mimeType: "application/json",
                    expectedContentLength: jsonData.count,
                    textEncodingName: "utf-8"
                )
                let cacheEntry = CachedURLResponse(response: response, data: jsonData)
                URLCache.shared.storeCachedResponse(cacheEntry, for: request)
                
                // 새로운 timestamp, URL 저장하기
                UserDefaults.standard.set(Date(), forKey: AppStorageKey.cacheCoinRecomTimestamp)
                UserDefaults.standard.set(cacheURL.absoluteString, forKey: AppStorageKey.cacheCoinRecomURL)
            } catch {
                throw NetworkError.encodingError
            }
        }
        return dto
    }
    
    /// 지정된 코인에 대한 개요 정보를 JSON으로 가져옵니다.
    ///
    /// 캐시가 있다면 캐시된 데이터를 먼저 반환하고, 없으면 새로 요청 후 캐싱합니다.
    /// - Parameter coin: 개요 정보를 요청할 코인
    /// - Returns: 디코딩된 개요 DTO
    func fetchOverview(for coin: Coin) async throws -> CoinOverviewDTO {
        // 캐시된 응답이 있으면 바로 반환
        let cacheURL = URL(string: "https://cache.local/coins/\(coin.id)/overview")!
        let request = URLRequest(url: cacheURL, cachePolicy: .returnCacheDataElseLoad)
        if let cachedResponse = URLCache.shared.cachedResponse(for: request) {
            do {
                return try JSONDecoder().decode(CoinOverviewDTO.self, from: cachedResponse.data)
            } catch let decodingError as DecodingError {
                throw NetworkError.decodingError(decodingError)
            }
        }
        
        let prompt = Prompt.generateOverView(coinKName: coin.koreanName)
        let dto: CoinOverviewDTO = try await fetchDTO(prompt: prompt, action: .coinReportGeneration)
        
        do {
            let jsonData = try JSONEncoder().encode(dto)
            
            let response = URLResponse(
                url: cacheURL,
                mimeType: "application/json",
                expectedContentLength: jsonData.count,
                textEncodingName: "utf-8"
            )
            let cacheEntry = CachedURLResponse(response: response, data: jsonData)
            URLCache.shared.storeCachedResponse(cacheEntry, for: request)
        } catch {
            throw NetworkError.encodingError
        }
        
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

    /// 2시간 단위 전체 시장 요약 데이터를 가져옵니다.
    /// 캐시가 유효하면 캐시를 우선 사용하고, 없거나 만료되면 새로 요청 후 캐싱합니다.
    ///
    /// - Parameter ignoreCache: 캐시 여부
    /// - Returns: 디코딩된 DTO
    func fetchTodayInsight(ignoreCache: Bool = false) async throws -> Insight {
        let now = Date.now
        let interval: TimeInterval = 60 * 60
        
        if !ignoreCache,
           !cacheBriefTodayTimestamp.isEmpty,
           let savedDate = Date.dateAndTimeFormatter.date(from: cacheBriefTodayTimestamp) {
            let cacheURL = URL(string: "https://cache.local/dashboard/today/\(cacheBriefTodayTimestamp)")!
            let request = URLRequest(url: cacheURL, cachePolicy: .returnCacheDataElseLoad)
            
            if let cachedResponse = URLCache.shared.cachedResponse(for: request),
               now.timeIntervalSince(savedDate) < interval {
                do {
                    let dto: InsightDTO = try JSONDecoder().decode(InsightDTO.self, from: cachedResponse.data)
                    return dto.toDomain()
                } catch let decodingError as DecodingError {
                    throw NetworkError.decodingError(decodingError)
                }
            }
        }
        
        let cacheURL = URL(string: "https://cache.local/dashboard/today/\(now.dateAndTime)")!
        let request = URLRequest(url: cacheURL, cachePolicy: .returnCacheDataElseLoad)
        
        let prompt = Prompt.generateTodayInsight
        let dto: InsightDTO = try await fetchDTO(prompt: prompt, action: .dashboardBriefingGeneration)
        
        do {
            let jsonData = try JSONEncoder().encode(dto)
            
            let response = URLResponse(
                url: cacheURL,
                mimeType: "application/json",
                expectedContentLength: jsonData.count,
                textEncodingName: "utf-8"
            )
            let cacheEntry = CachedURLResponse(response: response, data: jsonData)
            URLCache.shared.storeCachedResponse(cacheEntry, for: request)
        } catch {
            throw NetworkError.encodingError
        }
        
        if !cacheBriefTodayTimestamp.isEmpty {
            let oldCacheURL = URL(string: "https://cache.local/dashboard/today/\(cacheBriefTodayTimestamp)")!
            let oldRequest = URLRequest(url: oldCacheURL, cachePolicy: .returnCacheDataElseLoad)
            URLCache.shared.removeCachedResponse(for: oldRequest)
        }
        
        cacheBriefTodayTimestamp = now.dateAndTime
        
        return dto.toDomain()
    }
    
    /// 커뮤니티(예: Reddit) 게시글 요약을 기반으로 감정(`Sentiment`)과 요약을 생성합니다.
    /// 캐시가 유효하면 캐시를 우선 사용하고, 없거나 만료되면 새로 요청 후 캐싱합니다.
    ///
    /// - Parameters:
    ///   - post: 요약/분석할 커뮤니티 게시글 원문 문자열
    ///   - now: 캐시 키 생성을 위한 기준 시각(기본값: 현재 시각)
    ///   - ignoreCache: 캐시 무시 여부
    /// - Returns: 디코딩된 인사이트 도메인 모델
    /// - Throws: 네트워크 오류, 디코딩 오류, 인코딩 오류
    func fetchCommunityInsight(from post: String, now: Date = .now, ignoreCache: Bool = false) async throws -> Insight {
        let now = Date.now
        let interval: TimeInterval = 60 * 60
        
        if !ignoreCache,
           !cacheBriefCommunityTimestamp.isEmpty,
           let savedDate = Date.dateAndTimeFormatter.date(from: cacheBriefCommunityTimestamp) {
            let cacheURL = URL(string: "https://cache.local/dashboard/community/\(cacheBriefCommunityTimestamp)")!
            let request = URLRequest(url: cacheURL, cachePolicy: .returnCacheDataElseLoad)
            
            if let cachedResponse = URLCache.shared.cachedResponse(for: request),
               now.timeIntervalSince(savedDate) < interval {
                do {
                    let dto: InsightDTO = try JSONDecoder().decode(InsightDTO.self, from: cachedResponse.data)
                    return dto.toDomain()
                } catch let decodingError as DecodingError {
                    throw NetworkError.decodingError(decodingError)
                }
            }
        }
        
        let cacheURL = URL(string: "https://cache.local/dashboard/community/\(now.dateAndTime)")!
        let request = URLRequest(url: cacheURL, cachePolicy: .returnCacheDataElseLoad)
        
        let prompt = Prompt.generateCommunityInsight(redditPost: post)
        let dto: InsightDTO = try await fetchDTO(prompt: prompt, action: .dashboardBriefingGeneration)
        
        do {
            let jsonData = try JSONEncoder().encode(dto)
            
            let response = URLResponse(
                url: cacheURL,
                mimeType: "application/json",
                expectedContentLength: jsonData.count,
                textEncodingName: "utf-8"
            )
            let cacheEntry = CachedURLResponse(response: response, data: jsonData)
            URLCache.shared.storeCachedResponse(cacheEntry, for: request)
        } catch {
            throw NetworkError.encodingError
        }
        
        if !cacheBriefCommunityTimestamp.isEmpty {
            let oldCacheURL = URL(string: "https://cache.local/dashboard/community/\(cacheBriefCommunityTimestamp)")!
            let oldRequest = URLRequest(url: oldCacheURL, cachePolicy: .returnCacheDataElseLoad)
            URLCache.shared.removeCachedResponse(for: oldRequest)
        }
        
        cacheBriefCommunityTimestamp = Date.dateAndTimeFormatter.string(from: now)
        
        return dto.toDomain()
    }
    
    /// 북마크된 코인 전체에 대한 투자 브리핑과 전략 제안을 JSON 형식으로 가져옵니다.
    func fetchBookmarkBriefing(for coins: [BookmarkEntity], character: RiskTolerance) async throws -> PortfolioBriefingDTO {
        let coinNames = coins.map { $0.coinID }.joined(separator: ", ")

        // 온보딩 때 받을 투자 성향
        let importance: String
        switch character {
        case .conservative:
            importance = "원금 보전을 최우선으로 고려하며, 최근 가격 흐름이나 테마보다는 안정적인 종목 위주로 접근."

        case .moderatelyConservative:
            importance = "안정성을 중시하되, 일부 성장 가능성이 있는 종목도 보조적으로 고려하며, 단기 변동성에는 크게 영향을 받지 않음."

        case .moderate:
            importance = "안정성과 성장을 균형 있게 추구하며, 테마·시가 총액·최근 가격 흐름을 모두 균형적으로 참고."

        case .moderatelyAggressive:
            importance = "성장성을 우선시하되, 안정성도 일정 부분 고려하며, 최근 가격 흐름과 거래량 변화에 적극적으로 반응."

        case .aggressive:
            importance = "단기간의 높은 수익을 최우선으로 고려하며, 최근 가격 흐름과 거래량 변화를 중점적으로 참고하고, 테마는 보조적으로만 반영."
        }

        // 캐시 키 구성
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd"
        let today = formatter.string(from: Date())

        let bookmarkKey = coins.map { $0.coinID }.sorted().joined(separator: ",")
        let key = "\(today)_\(bookmarkKey)"

        let cacheURL = URL(string: "https://cache.local/bookmarkBriefing/\(key)")!
        let request = URLRequest(url: cacheURL, cachePolicy: .returnCacheDataElseLoad)

        // 캐시가 있다면 즉시 반환
        if let cachedResponse = URLCache.shared.cachedResponse(for: request) {
            return try JSONDecoder().decode(PortfolioBriefingDTO.self, from: cachedResponse.data)
        }

        let prompt = Prompt.generateBookmarkBriefing(importance: importance, bookmarks: coinNames)
        let answer = try await fetchAnswer(content: prompt.content, action: .bookmarkSuggestion)

        guard let jsonData = answer.content.extractedJSON.data(using: .utf8) else {
            throw DecodingError.dataCorrupted(
                DecodingError.Context(
                    codingPath: [],
                    debugDescription: "extractedJSON 문자열을 UTF-8 데이터로 변환 실패"
                )
            )
        }

        let dto = try JSONDecoder().decode(PortfolioBriefingDTO.self, from: jsonData)

        // 응답 캐싱
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
}
