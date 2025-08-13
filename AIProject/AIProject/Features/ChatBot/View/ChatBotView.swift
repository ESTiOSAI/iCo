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

            Group {
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
                        .padding(.top, 16)
                    }
                    .onChange(of: viewModel.messages) {
                        proxy.scrollTo(viewModel.messages.last?.id)
                    }
                }
                .padding(.bottom, 5) // TODO: 임시 패딩 ChatInputView가 Floating View로 변경되면 삭제될 예정.
                .padding(.horizontal, 16)
                .onTapGesture {
                    isFocused = false
                }

                ChatInputView(viewModel: viewModel, isFocused: $isFocused)
            }
            .background(.aiCoBackground)
        }
    }
}


#Preview {
    ChatBotView()
}
