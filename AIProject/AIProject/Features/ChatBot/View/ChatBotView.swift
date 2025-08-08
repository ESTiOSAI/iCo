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
            ScrollView(showsIndicators: false) {
                LazyVStack(spacing: 20) {
                    ForEach(viewModel.messages) { message in
                        if message.isUser {
                            BotMessageView(content: message.content)
                        } else {
                            UserMessageView(content: message.content)
                        }
                    }
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
    }
}

#Preview {
    ChatBotView()
}
