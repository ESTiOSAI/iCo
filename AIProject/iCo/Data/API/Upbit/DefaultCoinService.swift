//
//  DefaultCoinService.swift
//  AIProject
//
//  Created by kangho lee on 8/30/25.
//

import Foundation

final class DefaultCoinService: CoinService {
    private let network: NetworkClient
    private let endpoint: String = "https://api.upbit.com/v1"
    
    init(network: NetworkClient) {
        self.network = network
    }
    
    func meta() async throws -> [Coin] {
        let urlString = "\(endpoint)/market/all"
        guard let url = URL(string: urlString) else { throw NetworkError.invalidURL }
        let coinDTOs: [CoinDTO] = try await network.request(url: url)
        
        return coinDTOs
            .filter {
                $0.coinID.contains("KRW")
            }
            .map {
                Coin(id: $0.coinID, koreanName: $0.koreanName)
            }
    }
}
