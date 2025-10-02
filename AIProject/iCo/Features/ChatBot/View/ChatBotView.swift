//
//  ChatBot.swift
//  AIProject
//
//  Created by kangho lee on 7/29/25.
//

import SwiftUI

/// 챗봇의 최상위 View입니다.
struct ChatBotView: View {
    @Environment(\.horizontalSizeClass) var hSizeClass
    @Environment(\.verticalSizeClass) var vSizeClass
    @Environment(\.colorScheme) var colorScheme

    @StateObject private var viewModel = ChatBotViewModel()
    
    @State private var isPortrait: Bool = false
    @State private var isPad: Bool = false

    var body: some View {
        GeometryReader { proxy in
            VStack(spacing: 0) {
                HeaderView(heading: "챗봇")

                VStack(spacing: 0) {
                    ChatScrollView(viewModel: viewModel) {
                        LazyVStack(spacing: 20) {
                            ChatBotFAQView(viewModel: viewModel)
                            
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
                        .frame(maxWidth: isPortrait && isPad ? proxy.size.width * 0.6 : .infinity)
                        .padding(.horizontal, isPortrait && isPad ? 0 : 16)
                    }
                    .scrollIndicators(.hidden)
                    .frame(maxWidth: .infinity)

                    ChatInputView(viewModel: viewModel)
                        .frame(maxWidth: isPortrait && isPad ? proxy.size.width * 0.6 : .infinity)
                        .padding(.horizontal, isPortrait && isPad ? 0 : 16)
                }
                .background(.aiCoBackground.opacity(colorScheme == .light ? 1 : 0.5))
            }
            .frame(maxWidth: .infinity)
            .background(
                GeometryReader { proxy in
                    Color.clear
                        .onAppear {
                            if let orientation = UIApplication.shared.connectedScenes.compactMap({ $0 as? UIWindowScene }).first?.interfaceOrientation {
                                isPortrait = !orientation.isPortrait
                            }
                            
                            isPad = hSizeClass == .regular && vSizeClass == .regular
                        }
                        .onChange(of: proxy.size) {
                            if let orientation = UIApplication.shared.connectedScenes.compactMap({ $0 as? UIWindowScene }).first?.interfaceOrientation {
                                isPortrait = !orientation.isPortrait
                            }
                            
                            isPad = hSizeClass == .regular && vSizeClass == .regular
                        }
                }
            )
            .onTapGesture {
                viewModel.isTapped.toggle()
            }
        }
    }
}


#Preview {
    ChatBotView()
}
