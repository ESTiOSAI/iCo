//
//  ChatBotViewModel.swift
//  AIProject
//
//  Created by 강대훈 on 8/7/25.
//

import Foundation

struct ChatMessage: Identifiable {
    let content: String
    let isUser: Bool

    var id: Int { content.hashValue }
}

final class ChatBotViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    private let chatBotClient: ChatBotClient

    init(chatBotClient: ChatBotClient = ChatBotClient()) {
        self.chatBotClient = chatBotClient
    }

    func sendMessage(with content: String) async {
        do {
            await addMessage(with: content)
            try await chatBotClient.connect(content: content)
            try await observeStream()
        } catch {
            print(error.localizedDescription)
        }
    }

    private func observeStream() async throws {
        guard let stream = chatBotClient.stream else { return }

        for try await content in stream {
            try await Task.sleep(for: .seconds(0.05))
            await MainActor.run {
                if let message = messages.last(where: { !$0.isUser }) {
                    if let index = messages.lastIndex(where: { !$0.isUser }) {
                        messages[index] = ChatMessage(content: message.content + content, isUser: false)
                    }
                }
            }
        }
    }

    @MainActor
    private func addMessage(with content: String) {
        messages.append(ChatMessage(content: content, isUser: true))
        messages.append(ChatMessage(content: "", isUser: false))
    }
}
