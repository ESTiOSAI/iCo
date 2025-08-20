//
//  AlanAPIServiceProtocol.swift
//  AIProject
//
//  Created by kangho lee on 8/19/25.
//

import Foundation

protocol AlanAPIServiceProtocol {
    func fetchRecommendCoins(preference: String, bookmarkCoins: String) async throws -> [RecommendCoinDTO]
}
