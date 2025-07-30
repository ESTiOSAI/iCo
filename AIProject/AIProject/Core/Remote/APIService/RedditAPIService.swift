//
//  RedditAPIService.swift
//  AIProject
//
//  Created by 강대훈 on 7/30/25.
//

import Foundation

// TODO: 2차 스프린트에 fetchData(), DTO 수정 예정

final class RedditAPIService {
    private let network: NetworkClient
    private let endpoint: String = "https://oauth.reddit.com/r/cryptocurrency/top.json?t=day&limit=20"

    init(networkClient: NetworkClient = .init()) {
        self.network = networkClient
    }

    func fetchData() async throws -> [RedditDTO.RedditResponseDTO.RedditPostDTO] {
        let urlString = "\(endpoint)"
        let redditDTO: RedditDTO = try await network.request(url: URL(string: urlString)!)

        return redditDTO.data.children
    }
}
