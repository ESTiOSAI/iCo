//
//  RedditAPIService.swift
//  AIProject
//
//  Created by 강대훈 on 7/30/25.
//

import Foundation

enum RedditEndpoint {
    case main
}

extension RedditEndpoint: Requestable {
    var baseURL: String { "https://oauth.reddit.com" }
    var path: String { "/r/cryptocurrency/top.json" }
    var httpMethod: HTTPMethod { .get }
    var queryParameters: Encodable? { ["t": "day", "limit": "5"] }
    var bodyParameters: Encodable? { nil }
    var headers: [String : String] { [:] }
}

/// 레딧 API 관련 서비스를 제공합니다.
final class RedditAPIService: CommunityProvider {
    private let network: NetworkClient
    
    init(networkClient: NetworkClient = .init()) {
        self.network = networkClient
    }
    
    /// Reddit의 r/cryptocurrency 서브레딧에서 인기 게시글 데이터를 가져옵니다.
    /// - Returns: 결과는 배열로 반환되며, 각 요소는 하나의 게시글 정보를 포함합니다.
    func fetchData() async throws -> [RedditDTO.RedditResponseDTO.RedditPostDTO] {
        let urlRequest = try RedditEndpoint.main.makeURLrequest()
        let redditDTO: RedditDTO = try await network.request(for: urlRequest)
        return redditDTO.data.children
    }
}
