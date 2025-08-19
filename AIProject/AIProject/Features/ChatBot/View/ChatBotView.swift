//
//  ChatBot.swift
//  AIProject
//
//  Created by kangho lee on 7/29/25.
//

import SwiftUI

struct ChatBotView: View {
    @StateObject private var viewModel = ChatBotViewModel()

    @State private var searchText: String = ""
    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(spacing: 0) {
            HeaderView(heading: "챗봇")

            ChatScrollView(viewModel: viewModel) {
                LazyVStack(spacing: 20) {
                    ForEach(viewModel.messages) { message in
                        Group {
                            if message.isUser {
                                UserMessageView(content: message.content)
                            } else {
                                BotMessageView(message: message)
                            }
                        }
                        .id(message.id)
                    }
                }
                .padding(.horizontal, 16)
            }

            ChatInputView(viewModel: viewModel, isFocused: $isFocused)
        }
        .onTapGesture {
            isFocused = false
        }
        .background(.aiCoBackground)
    }
}



