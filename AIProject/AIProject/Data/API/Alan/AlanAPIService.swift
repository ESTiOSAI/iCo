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
    
    /// 사용자의 투자 성향과 관심 코인을 기반으로 추천 코인 목록을 요청합니다.
    ///
    /// 캐시가 있다면 캐시된 데이터를 먼저 반환하고, 없으면 새로 요청 후 캐싱합니다.
    /// - Parameters:
    ///   - preference: 사용자의 투자 성향을 나타내는 문자열입니다.
    ///     예: `"초보자"`, `"중수"`, `"고수"`
    ///   - bookmarkCoins: 사용자가 북마크한 코인 이름을 쉼표로 구분한 문자열입니다.
    ///     예: `"비트코인,이더리움"`
    func fetchRecommendCoins(preference: String, bookmarkCoins: String) async throws -> [RecommendCoinDTO] {
        let interval: TimeInterval = 60 * 60
        var dto = [RecommendCoinDTO]()
        
        // timestamp, 투자 성향, 북마크를 가지고 URL을 생성해주는 헬퍼 함수
        lazy var cacheURL: URL? = {
            let currentTimestamp = Date().numbersOnly
            let cacheKey = "\(currentTimestamp)_\(preference)_\(bookmarkCoins)"
            return URL(string: "https://cache.local/coinRecommendation/\(cacheKey)")
        }()
        
#if DEBUG
//        UserDefaults.standard.removeObject(forKey: AppStorageKey.cacheCoinRecomTimestamp)
//        UserDefaults.standard.removeObject(forKey: AppStorageKey.cacheCoinRecomURL)
//        URLCache.shared.removeCachedResponse(for: URLRequest(url: URL(string: AppStorageKey.cacheCoinRecomURL)!))
#endif
        
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
        
        guard let cacheURL else { return [] }
        
        let request = URLRequest(url: cacheURL, cachePolicy: .returnCacheDataElseLoad)
        
        // 기존 캐시 확인하기
        if let cachedResponse = URLCache.shared.cachedResponse(for: request) {
            print("▶️ 캐시 사용: ", request.url!)
            dto = try JSONDecoder().decode([RecommendCoinDTO].self, from: cachedResponse.data)
        } else {
            print("▶️ 캐시 없음")
            let prompt = Prompt.recommendCoin(preference: preference, bookmark: bookmarkCoins)
#if DEBUG
            dto = [
                AIProject.RecommendCoinDTO(
                    name: "테더",
                    symbol: "USDT",
                    comment: "테더는 미국 달러와 1:1로 연동된 스테이블 코인으로, 가격 변동성이 적어 보수적인 투자자에게 적합합니다. 최근 많은 거래소에서 주요 거래 쌍으로 사용되며, 안정적인 가치 저장 수단으로 자리잡고 있습니다."
                ), AIProject.RecommendCoinDTO(
                    name: "USD 코인",
                    symbol: "USDC",
                    comment: "USD 코인은 미국 달러와 연동된 스테이블 코인으로, 높은 투명성과 규제 준수로 신뢰를 얻고 있습니다. 최근 금융 기관들과의 협력으로 사용처가 확대되고 있으며, 보수적인 투자자에게 안전한 선택지로 추천됩니다."
                ), AIProject.RecommendCoinDTO(
                    name: "다이",
                    symbol: "DAI",
                    comment: "다이는 탈중앙화된 스테이블 코인으로, 이더리움 기반의 스마트 계약을 통해 가격을 안정적으로 유지합니다. 최근 디파이 플랫폼에서의 사용이 증가하며, 보수적인 투자자에게 안정적인 투자 옵션으로 추천됩니다."
                ), AIProject.RecommendCoinDTO(
                    name: "리플",
                    symbol: "XRP",
                    comment: "리플은 금융 기관 간의 빠른 국제 송금을 지원하는 암호화폐로, 최근 법적 분쟁에서 긍정적인 결과를 얻으며 신뢰를 회복하고 있습니다. 보수적인 투자자에게는 안정적인 금융 기술 기반의 코인으로 추천할 만합니다."
                ), AIProject.RecommendCoinDTO(
                    name: "폴카닷",
                    symbol: "DOT",
                    comment: "폴카닷은 여러 블록체인을 연결하여 상호 운용성을 제공하는 플랫폼으로, 최근 파라체인 경매가 성공적으로 진행되며 생태계가 확장되고 있습니다. 보수적인 투자자에게는 다각화된 네트워크로서의 가능성을 이유로 추천합니다."
                ), AIProject.RecommendCoinDTO(
                    name: "카르다노",
                    symbol: "ADA",
                    comment: "카르다노는 스마트 계약 기능을 제공하며, 지속 가능한 블록체인 기술을 목표로 합니다. 최근 주요 업그레이드를 통해 성능이 개선되었으며, 이는 보수적인 투자자들에게 긍정적인 신호로 작용하고 있습니다."
                ), AIProject.RecommendCoinDTO(
                    name: "체인링크",
                    symbol: "LINK",
                    comment: "체인링크는 스마트 계약과 외부 데이터를 연결하는 오라클 네트워크로, 최근 다양한 파트너십을 통해 생태계를 확장하고 있습니다. 보수적인 투자자에게는 실용적인 응용 가능성을 이유로 추천합니다."
                ), AIProject.RecommendCoinDTO(
                    name: "테조스",
                    symbol: "XTZ",
                    comment: "테조스는 자체적인 업그레이드 기능을 통해 지속적으로 발전하는 블록체인 플랫폼입니다. 최근 다양한 디앱과 NFT 프로젝트가 테조스에서 시작되며 활기를 띠고 있습니다. 보수적인 투자자에게는 자가 수정 가능한 프로토콜로서의 장점을 이유로 추천합니다."
                ), AIProject.RecommendCoinDTO(
                    name: "아발란체",
                    symbol: "AVAX",
                    comment: "아발란체는 높은 처리량과 빠른 거래 확정 시간을 제공하는 블록체인 플랫폼입니다. 최근 디파이와 NFT 분야에서의 활발한 활동이 주목받고 있습니다. 보수적인 투자자에게는 확장성과 혁신성을 이유로 추천합니다."
                ), AIProject.RecommendCoinDTO(
                    name: "코스모스",
                    symbol: "ATOM",
                    comment: "코스모스는 여러 블록체인 간의 상호 운용성을 제공하는 플랫폼입니다. 최근 IBC 프로토콜을 통해 다양한 블록체인과의 연결이 강화되며 주목받고 있습니다. 보수적인 투자자에게는 네트워크 확장성과 상호 운용성을 이유로 추천합니다."
                )
            ]
#else
            dto = try await fetchDTO(prompt: prompt, action: .coinRecomendation)
#endif
            
            // 이전 캐시가 남아있다면 삭제하기
            if let lastCacheURLString = UserDefaults.standard.value(forKey: AppStorageKey.cacheCoinRecomURL) as? String,
               let lastCacheURL = URL(string: lastCacheURLString) {
                URLCache.shared.removeCachedResponse(for: URLRequest(url: lastCacheURL))
                print("▶️ 캐시 삭제: ", lastCacheURLString)
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
                
                print("▶️ 캐시 생성: ", request.url!)
                
                // 새로운 timestamp, URL 저장하기
                UserDefaults.standard.set(Date(), forKey: AppStorageKey.cacheCoinRecomTimestamp)
                UserDefaults.standard.set(cacheURL.absoluteString, forKey: AppStorageKey.cacheCoinRecomURL)
            } catch {
                throw NetworkError.encodingError
            }
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

    /// 주어진 코인에 대해 2시간 단위 전체 시장 요약 데이터를 가져옵니다.
    ///
    /// 캐시가 있다면 캐시된 데이터를 먼저 반환하고, 없으면 새로 요청 후 캐싱합니다.
    /// - Parameter coin: 대상 코인
    /// - Returns: 디코딩된 DTO
    func fetchTodayInsight(now: Date = .now) async throws -> Insight {
        let insightTTL: TimeInterval = 60 * 60
        
        if !cacheBriefTodayTimestamp.isEmpty,
           let savedDate = Date.dateAndTimeFormatter.date(from: cacheBriefTodayTimestamp) {
            let cacheURL = URL(string: "https://cache.local/dashboard/today/\(cacheBriefTodayTimestamp)")!
            let request = URLRequest(url: cacheURL, cachePolicy: .returnCacheDataElseLoad)
            
            if let cachedResponse = URLCache.shared.cachedResponse(for: request),
                now.timeIntervalSince(savedDate) < insightTTL {
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
    
    /// 주어진 코인에 대해 커뮤니티 기반 인사이트 데이터를 가져옵니다.
    ///
    /// 캐시가 있다면 캐시된 데이터를 먼저 반환하고, 없으면 새로 요청 후 캐싱합니다.
    /// - Parameter coin: 대상 코인
    /// - Returns: 디코딩된 DTO
    func fetchCommunityInsight(from post: String, now: Date = .now) async throws -> Insight {
        let insightTTL: TimeInterval = 60 * 60
        
        if !cacheBriefCommunityTimestamp.isEmpty,
           let savedDate = Date.dateAndTimeFormatter.date(from: cacheBriefCommunityTimestamp) {
            let cacheURL = URL(string: "https://cache.local/dashboard/community/\(cacheBriefCommunityTimestamp)")!
            let request = URLRequest(url: cacheURL, cachePolicy: .returnCacheDataElseLoad)
            
            if let cachedResponse = URLCache.shared.cachedResponse(for: request),
                now.timeIntervalSince(savedDate) < insightTTL {
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
    func fetchBookmarkBriefing(for coins: [BookmarkEntity], character: InvestmentCharacter) async throws -> PortfolioBriefingDTO {
        let coinNames = coins.map { $0.coinID }.joined(separator: ", ")

        // 온보딩 때 받을 투자 성향
        let importance: String
        switch character {
        case .shortTerm:
            importance = "최근 가격 흐름과 거래량 변화를 최우선으로 고려하며, 테마는 보조적으로 참고."
        case .longTerm:
            importance = "테마, 시가 총액의 안정성과 성장성을 최우선으로 고려하며, 최근 가격 흐름과 거래량은 보조적으로 참고."
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
            print("캐시 사용")
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
