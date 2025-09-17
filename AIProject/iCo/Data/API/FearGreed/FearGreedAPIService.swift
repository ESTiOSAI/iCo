//
//  FearGreedAPIService.swift
//  AIProject
//
//  Created by 장지현 on 8/6/25.
//

import Foundation

enum FearGreedEndpoint {
    case main
}

extension FearGreedEndpoint: Requestable {
    var baseURL: String { "https://api.alternative.me" }
    var path: String { "/fng" }
    var httpMethod: HTTPMethod { .get }
    var queryParameters: Encodable? { nil }
    var bodyParameters: Encodable? { nil }
    var headers: [String : String] { [:] }
}

/// 공포 탐욕 지수 API 관련 서비스를 제공합니다.
final class FearGreedAPIService: FearGreedProvider {
    let network: NetworkClient

    init(networkClient: NetworkClient = .init()) {
        self.network = networkClient
    }
    
    /// Alternative의 공포 탐욕 지수 데이터를 가져옵니다.
    /// - Returns: 공포 탐욕 지수, 상태 정보
    func fetchData() async throws -> [FearGreedIndexDTO] {
        let urlRequest = try FearGreedEndpoint.main.makeURLrequest()
        let fearGreedResponseDTO: FearGreedResponseDTO = try await network.request(for: urlRequest)
        return fearGreedResponseDTO.data
    }
}

