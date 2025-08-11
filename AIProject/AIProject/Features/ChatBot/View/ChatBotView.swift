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
        NavigationStack {
            VStack(spacing: 15) {
                ScrollViewReader { proxy in
                    ScrollView(showsIndicators: false) {
                        LazyVStack(spacing: 20) {
                            ForEach(viewModel.messages) { message in
                                Group {
                                    if message.isUser {
                                        UserMessageView(content: message.content)
                                    } else {
                                        BotMessageView(content: message.content)
                                    }
                                }
                                .id(message.id)
                            }
                        }
                    }
                    .onChange(of: viewModel.messages) {
                        proxy.scrollTo(viewModel.messages.last?.id, anchor: .bottom)
                    }
                }
                .padding(.horizontal)
                .navigationTitle("챗봇")
                .navigationBarTitleDisplayMode(.large)
                .onTapGesture {
                    isFocused = false
                }

                ChatInputView(viewModel: viewModel, isFocused: $isFocused)
            }
            .background(Color.aiCoBackgroundWhite)
        }
    }
}

#Preview {
    ChatBotView()
}
