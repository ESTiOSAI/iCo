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
        VStack(spacing: 10) {
            HeaderView(heading: "챗봇")

            ScrollViewReader { proxy in
                ScrollView(showsIndicators: false) {
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
                }
                .onChange(of: viewModel.messages) {
                    proxy.scrollTo(viewModel.messages.last?.id)
                }
            }
            .padding(.horizontal)
            .onTapGesture {
                isFocused = false
            }

            ChatInputView(viewModel: viewModel, isFocused: $isFocused)
        }
        .background(Color.aiCoBackground)
    }
}


#Preview {
    ChatBotView()
}
