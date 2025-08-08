//
//  CoinGeckoService.swift
//  AIProject
//
//  Created by 백현진 on 8/8/25.
//

import Foundation

/// CoinGecko에서 코인 이미지(URL)를 조회하는 서비스를 제공합니다.
final class CoinGeckoAPIService {
    private let network: NetworkClient
    private let endpoint: String = "https://api.coingecko.com/api/v3"

    init(network: NetworkClient = .init()) {
        self.network = network
    }

    /// 지정한 심볼 집합에 해당하는 코인들의 이미지 정보를 조회합니다.
    /// - Parameters:
    ///   - symbols: 코인 심볼 배열 (ex. ["btc", "eth", "bonk"])
    ///   - vsCurrency: 표기 통화 (가격을 쓰지 않더라도 엔드포인트 특성상 필요, 기본: "krw")
    /// - Returns: 이미지 정보를 포함한 DTO 배열
    func fetchCoinImages(symbols: [String], vsCurrency: String = "krw") async throws -> [CoinGeckoImageDTO] {
        let trimmed = symbols
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() }
            .filter { !$0.isEmpty }

        guard !trimmed.isEmpty else { return [] }

        var comps = URLComponents(string: "\(endpoint)/coins/markets")
        comps?.queryItems = [
            URLQueryItem(name: "vs_currency", value: vsCurrency.lowercased()),
            URLQueryItem(name: "symbols", value: trimmed.joined(separator: ","))
        ]

        guard let url = comps?.url else { throw NetworkError.invalidURL }
        print("🧭 [GECKO] symbols=\(trimmed)")
            print("🔗 [GECKO] URL=\(url.absoluteString)")

        let dtos: [CoinGeckoImageDTO] = try await network.request(url: url)
		print("dtos: \(dtos)")
        return dtos
    }

    /// 심볼 → 이미지 URL 매핑을 조회합니다.
    /// - Parameters:
    ///   - symbols: 코인 심볼 배열 (대소문자 무관)
    ///   - vsCurrency: 표기 통화 (기본: "krw")
    /// - Returns: ["BTC": URL, "ETH": URL, ...]
    func fetchImageMap(symbols: [String], vsCurrency: String = "krw") async throws -> [String: URL] {
        let dtos = try await fetchCoinImages(symbols: symbols, vsCurrency: vsCurrency)
        return Dictionary(uniqueKeysWithValues: dtos.map { ($0.symbol.uppercased(), $0.imageURL) })
            .compactMapValues { $0 }
    }


    /// 북마크 엔티티 목록으로 이미지를 조회합니다. (coinSymbol 계산속성 사용 가정)
    /// - Returns: ["BTC": URL, ...]
    func fetchImageMapForBookmarks(_ bookmarks: [BookmarkEntity], vsCurrency: String = "krw") async throws -> [String: URL] {
        let symbols = bookmarks.map { ($0.coinID.split(separator: "-").last.map(String.init) ?? $0.coinID) }
        return try await fetchImageMap(symbols: symbols, vsCurrency: vsCurrency)
    }
}

