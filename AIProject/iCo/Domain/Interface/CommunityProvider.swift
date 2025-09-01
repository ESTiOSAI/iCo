//
//  CommunityProvider.swift
//  AIProject
//
//  Created by kangho lee on 8/19/25.
//

import Foundation

protocol CommunityProvider {
    func fetchData() async throws -> [RedditDTO.RedditResponseDTO.RedditPostDTO]
}
