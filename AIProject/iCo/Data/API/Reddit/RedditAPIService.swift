//
//  RedditAPIService.swift
//  AIProject
//
//  Created by 강대훈 on 7/30/25.
//

import Foundation

/// 레딧 API 관련 서비스를 제공합니다.
final class RedditAPIService: CommunityProvider {
    private let network: NetworkClient
    private let endpoint: String = "https://oauth.reddit.com/r/cryptocurrency/top.json?t=day&limit=5"
    
    init(networkClient: NetworkClient = .init()) {
        self.network = networkClient
    }
    
    /// Reddit의 r/cryptocurrency 서브레딧에서 인기 게시글 데이터를 가져옵니다.
    /// - Returns: 결과는 배열로 반환되며, 각 요소는 하나의 게시글 정보를 포함합니다.
    func fetchData() async throws -> [RedditDTO.RedditResponseDTO.RedditPostDTO] {
        let urlString = "\(endpoint)"
        guard let url = URL(string: urlString) else { throw NetworkError.invalidURL }
        let redditDTO: RedditDTO = try await network.request(url: url)
        
        return redditDTO.data.children
    }
}
