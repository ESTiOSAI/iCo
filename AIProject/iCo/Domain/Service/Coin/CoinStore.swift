//
//  CoinStore.swift
//  AIProject
//
//  Created by kangho lee on 8/30/25.
//

import Foundation

protocol CoinService {
    func meta() async throws -> [Coin]
}

@Observable
final class CoinStore {
    private let coinService: CoinService
    
    var coins: [CoinID: Coin] = [:]
    
    init(coinService: CoinService) {
        self.coinService = coinService
    }
    
    func loadCoins() async {
        do {
            coins = try await coinService.meta()
                .reduce(into: [CoinID: Coin]()) {
                    $0[$1.id] = $1
                }
        } catch {
            coins = [:]
        }
    }
}
