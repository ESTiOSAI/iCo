//
//  RedditResponseDTO.swift
//  AIProject
//
//  Created by 강대훈 on 7/30/25.
//

import Foundation

/// Reddit 응답 DTO
// TODO: 수정 가능성이 높습니다. (2차 스프린트)
struct RedditDTO: Codable {
    let data: RedditResponseDTO

    struct RedditResponseDTO: Codable {
        let children: [RedditPostDTO]

        struct RedditPostDTO: Codable {
            let data: RedditPostDetailDTO

            struct RedditPostDetailDTO: Codable {
                let title: String
                let content: String

                enum CodingKeys: String, CodingKey {
                    case title
                    case content = "selftext"
                }
            }
        }
    }
}
