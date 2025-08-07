//
//  ChatDTO.swift
//  AIProject
//
//  Created by 강대훈 on 8/7/25.
//

import Foundation

struct ChatDTO: Codable {
    let id: String
    let choices: [Choice]

    struct Choice: Codable {
        let delta: Delta
        let finish_reason: String?

        struct Delta: Codable {
            let content: String
        }
    }
}
