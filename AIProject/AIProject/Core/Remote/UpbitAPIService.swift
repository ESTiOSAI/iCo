//
//  APIService.swift
//  AIProject
//
//  Created by 강대훈 on 7/30/25.
//

import Foundation

final class UpBitAPIService {
    let network: NetworkClient
    let endpoint: String = "https://api.upbit.com/v1"

    init(networkClient: NetworkClient) {
        self.network = networkClient
    }

    func fetchMarkets() async throws -> [MarketDTO] {
        let urlString = "\(endpoint)/market/all"
        let markets: [MarketDTO] = try await network.request(url: URL(string: urlString)!)

        //MARK: Test
        dump(markets)

		return markets
    }
}
