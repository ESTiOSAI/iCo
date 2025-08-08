//
//  ChatMessage.swift
//  AIProject
//
//  Created by 강대훈 on 8/8/25.
//

struct ChatMessage: Identifiable {
    let content: String
    let isUser: Bool

    var id: Int { content.hashValue }
}
