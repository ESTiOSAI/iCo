//
//  CoinImageProvider.swift
//  AIProject
//
//  Created by kangho lee on 8/19/25.
//

import Foundation

protocol CoinImageProvider {
    func fetchCoinImages(symbols: [String], vsCurrency: String) async throws -> [CoinGeckoImageDTO]
    func fetchCoinImagesBatched(
        symbols: [String],
        vsCurrency: String,
        batchSize: Int,
        maxConcurrentBatches: Int
    ) async -> [CoinGeckoImageDTO]
    
    func fetchImageMapBatched(
        symbols: [String],
        vsCurrency: String,
        batchSize: Int,
        maxConcurrentBatches: Int
    ) async -> [String: URL]
    
    func fetchCoinImagesByIDs(ids: [String], vsCurrency: String) async throws -> [CoinGeckoImageDTO]
    
    func fetchImageMapByEnglishNames(
        englishNames: [String],
        vsCurrency: String
    ) async -> [String: URL]
    
    func fetchImageBy(
        symbols: [String],
        currency: String,
        chunkSize: Int
    ) async -> [String: URL]
}
