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
                            HStack {
                                Spacer()
                                Text(message.content)
                                    .font(.system(size: 13))
                                    .padding(15)
                                    .background(Color.blue.opacity(0.2))
                                    .frame(maxWidth: 300, alignment: .trailing)
                            }
                        } else {
                            HStack {
                                VStack {
                                    Image(systemName: "swift")
                                        .padding(8)
                                        .background(Circle().stroke(Color.gray.opacity(0.3), lineWidth: 1))
                                    Spacer()
                                }

                                Text(message.content)
                                    .font(.system(size: 13))
                                    .padding()
                                    .background(Color.red.opacity(0.2))
                                    .frame(maxWidth: 300, alignment: .leading)
                                Spacer()
                            }
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

            HStack {
                TextField("무엇이든 물어보세요.", text: $searchText)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .cornerRadius(20)
                    .focused($isFocused)

                Button {
                    Task {
                        await viewModel.sendMessage(with: searchText)
                    }
                } label: {
                    Image(systemName: "arrow.up")
                        .padding(10)
                        .background(Circle().stroke(Color.gray.opacity(0.3), lineWidth: 1))
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(
                RoundedRectangle(cornerRadius: 30)
                    .stroke(Color.gray.opacity(0.5), lineWidth: 1)
            )
            .padding(.horizontal)
            .padding(.bottom, 10)
        }
    }
}

#Preview {
    ChatBotView()
}
