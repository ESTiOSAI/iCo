//
//  ChatBotViewModel.swift
//  AIProject
//
//  Created by 강대훈 on 8/7/25.
//

import Foundation

final class ChatBotViewModel: ObservableObject {
    /// 사용자와 챗봇의 메세지를 담은 배열입니다.
    @Published private(set) var messages: [ChatMessage] = []
    @Published private(set) var isEditable: Bool = false

    @Published private(set) var isStreaming: Bool = false {
        didSet {
            Task { @MainActor in
                checkValid()
            }
        }
    }

    @Published var searchText: String = "" {
        didSet {
            Task { @MainActor in
                checkValid()
            }
        }
    }

    /// 서버와 통신하는 클라이언트입니다.
    private let chatBotClient: ChatBotClient

    init(chatBotClient: ChatBotClient = ChatBotClient()) {
        self.chatBotClient = chatBotClient
    }

    /// 사용자가 입력한 메시지를 전송하고, 챗봇 응답 스트림을 관찰하여 UI에 반영합니다.
    /// - Parameter content: 사용자가 전송하는 메세지 내용입니다.
    func sendMessage() async {
        let message = searchText

        Task { @MainActor in searchText = "" }
        await MainActor.run { isStreaming = true }

        do {
            await addMessage(with: message)
            try await chatBotClient.connect(content: message)
            try await observeStream()
        } catch {
            print(error.localizedDescription)
        }

        await MainActor.run { isStreaming = false }
    }

    /// 챗봇 SSE 스트림을 관찰하여 토큰 단위로 UI에 메시지를 업데이트합니다.
    private func observeStream() async throws {
        guard let stream = chatBotClient.stream else { return }

        for try await content in stream {
            await MainActor.run {
                if let message = messages.last(where: { !$0.isUser }) {
                    if let index = messages.lastIndex(where: { !$0.isUser }) {
                        messages[index] = ChatMessage(content: message.content + content, isUser: false)
                    }
                }
            }
        }
    }

    /// 사용자 메시지와 빈 챗봇 응답 메시지를 목록에 추가합니다.
    /// - Parameter content: 사용자의 메시지 내용입니다.
    ///
    /// 이 메소드는 메인 쓰레드에서 실행됩니다.
    @MainActor
    private func addMessage(with content: String) {
        messages.append(ChatMessage(content: content, isUser: true))
        messages.append(ChatMessage(content: "", isUser: false))
    }

    @MainActor
    private func checkValid() {
        isEditable = !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !isStreaming
    }
}
