//
//  ChatMessage.swift
//  AIProject
//
//  Created by 강대훈 on 8/8/25.
//

import Foundation

struct ChatMessage: Identifiable, Equatable {
    let content: String
    let isUser: Bool
    let isError: Bool
    let id: UUID

    init(content: String, isUser: Bool, isError: Bool = false) {
        self.content = content
        self.isUser = isUser
        self.isError = isError
        self.id = UUID()
    }
}
