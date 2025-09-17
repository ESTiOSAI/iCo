//
//  CoinGeckoService.swift
//  AIProject
//
//  Created by 백현진 on 8/8/25.
//

import Foundation

/// CoinGecko에서 코인 이미지(URL)를 조회하는 서비스를 제공합니다.
final class CoinGeckoAPIService: CoinImageProvider {
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
    func fetchCoinImages(symbols: [String], vsCurrency: String = "krw") async throws -> [CoinGeckoImageDTO] { // MARK: Request
        let urlRequest = try CoinGeckoEndpoint.bySymbol(symbols: symbols, currency: vsCurrency).makeURLrequest()
        let dtos: [CoinGeckoImageDTO] = try await network.request(for: urlRequest)
        return dtos
    }
    
    //MARK: -- 온보딩 뷰에서 저장하는 새로운 fetch
    func fetchCoinImagesByIDs(ids: [String], vsCurrency: String = "krw") async throws -> [CoinGeckoImageDTO] { // MARK: Request
        let urlRequest = try CoinGeckoEndpoint.byID(ids: ids, currency: vsCurrency).makeURLrequest()
        let dtos: [CoinGeckoImageDTO] = try await network.request(for: urlRequest)
        return dtos
    }

    func fetchCoinImagesBatched(
        symbols: [String],
        vsCurrency: String = "krw",
        batchSize: Int = 50,
        maxConcurrentBatches: Int = 3
    ) async -> [CoinGeckoImageDTO] {

        let uniq = Array(Set(
            symbols
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { !$0.isEmpty }
                .map { $0.lowercased() }
        ))

        guard !uniq.isEmpty else { return [] }

        let chunks = uniq.chunked(into: batchSize)
        var results: [CoinGeckoImageDTO] = []

        // 병럴 처리
        var start = 0
        while start < chunks.count {
            let end = min(start + maxConcurrentBatches, chunks.count)
            let window = Array(chunks[start..<end])
            start = end

            await withTaskGroup(of: [CoinGeckoImageDTO].self) { group in
                for chunk in window {
                    group.addTask { [vsCurrency] in
                        do {
                            return try await self.fetchCoinImages(symbols: chunk, vsCurrency: vsCurrency)
                        } catch {
                            print("네트워크 에러처리", error.localizedDescription)
                            return []
                        }
                    }
                }

                for await part in group {
                    results.append(contentsOf: part)
                }
            }
        }

        return results
    }

    /// symbols가 50개를 초과해도 배치로 모두 조회해 ["BTC": URL] 형태로 리턴합니다.
    func fetchImageMapBatched(
        symbols: [String],
        vsCurrency: String = "krw",
        batchSize: Int = 50,
        maxConcurrentBatches: Int = 3
    ) async -> [String: URL] {

        let dtos = await fetchCoinImagesBatched(
            symbols: symbols,
            vsCurrency: vsCurrency,
            batchSize: batchSize,
            maxConcurrentBatches: maxConcurrentBatches
        )

        // 키는 대문자 심볼로 통일
        return Dictionary(uniqueKeysWithValues:
                            dtos.compactMap { dto in
            guard let url = dto.imageURL else { return nil }
            return (dto.symbol.uppercased(), url)
        }
        )
    }

    func fetchImageMapByEnglishNames(
        englishNames: [String],
        vsCurrency: String = "krw"
    ) async -> [String: URL] {
        do {
            // 1. 메타 데이터(API로 이미지 URL 목록 가져오기)
            let dtos: [CoinGeckoImageDTO]
            
            if englishNames.count > 100 {
                let start = Array(englishNames[0..<100])
                let end = Array(englishNames[100..<englishNames.count])
                
                async let firstBatch = try await fetchCoinImagesByIDs(ids: start, vsCurrency: vsCurrency)
                async let secondBatch = try await fetchCoinImagesByIDs(ids: end, vsCurrency: vsCurrency)
                let firstDTO = try await firstBatch
                let secondDTO = try await secondBatch
                //print("batch result: \(firstDTO.count)개, \(secondDTO.count)개")
                dtos = firstDTO + secondDTO
            } else {
                dtos = try await fetchCoinImagesByIDs(ids: englishNames, vsCurrency: vsCurrency)
            }
            
            return await withTaskGroup(of: (String, URL).self) { group in
                for dto in dtos {
                    guard let url = dto.imageURL else { continue }
                    let symbol = dto.symbol.uppercased()
                    
                    group.addTask {
                        // 미리 캐싱 — 네트워크 요청이 필요해도 URLCache에 저장됨
                        // main thread log남겨보기
                        Task.detached(priority: .background) { [url] in
                            do {
                                try await ImageLoader.shared.image(for: url)
                            } catch {
                                print("이미지 로딩 에러:", error.localizedDescription)
                            }
                        }
                        return (symbol, url)
                    }
                }
            
                var result: [String: URL] = [:]
                for await (symbol, url) in group {
                    result[symbol] = url
                }
                return result
            }
        } catch {
            print("네트워크 에러:", error.localizedDescription)
            return [:]
        }
    }
}

extension CoinGeckoAPIService {
    
    /// 업베트와 게코의 englishName이 차이가 나서 50개 제한이있는 symbol로 검색해야함
    /// - Parameters:
    ///   - symbols: 소문자 - btc
    ///   - currency: 통화 - krw
    ///   - chunkSize: default 50개
    /// - Returns: 이미지 맵
    func fetchImageBy(symbols: [String], currency: String = "krw", chunkSize: Int = 50) async -> [String: URL] {
        
        let dtos = await fetchImageMapBatched(symbols: symbols)
        
        return await withTaskGroup(of: (String, URL).self) { group in
            for (symbol, url) in dtos {
                group.addTask {
                    Task.detached(priority: .background) { [url] in
                        do {
                            try await ImageLoader.shared.image(for: url)
                        } catch {
                            print("이미지 로딩 에러:", error.localizedDescription)
                        }
                    }
                    return (symbol, url)
                }
            }
            
            var result: [String: URL] = [:]
            for await (symbol, url) in group {
                result[symbol] = url
            }
            return result
        }
    }
}
