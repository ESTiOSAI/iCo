//
//  FAQView 2.swift
//  iCo
//
//  Created by 강대훈 on 10/1/25.
//


import SwiftUI

struct ChatBotFAQView: View {
    @Environment(\.colorScheme) var colorScheme
    
    @ObservedObject var viewModel: ChatBotViewModel
    
    var body: some View {
        HStack {
            VStack {
                Image("logo")
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 34)
                    .foregroundColor(colorScheme == .light ? .aiCoAccent : .aiCoLabel)
                    .opacity(0.8)
                    .padding(12)
                    .overlay {
                        Circle()
                            .strokeBorder(.accentGradient, lineWidth: 0.5)
                    }
                    .background {
                        Circle()
                            .fill(.aiCoBackgroundBlue)
                    }
                Spacer()
            }

            Group {
                VStack(spacing: 15) {
                    HStack {
                        Text("안녕하세요, 아이코 챗봇입니다.\n궁금하신 내용을 선택해주세요.")
                            .font(.system(size: 15))
                        Spacer()
                    }
                    
                    ForEach(ChatBotFAQ.allCases) { faq in
                        Button {
                            Task { await viewModel.sendMessage(message: faq.rawValue) }
                        } label: {
                            Text(faq.rawValue)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .font(.system(size: 14))
                        .background(.aiCoBackgroundAccent)
                        .clipShape(RoundedRectangle(cornerRadius: 15))
                        .overlay(RoundedRectangle(cornerRadius: 15).strokeBorder(.accentGradient, lineWidth: 0.5))
                        .disabled(viewModel.isStreaming)
                    }
                }
            }
            .foregroundStyle(.aiCoLabel)
            .font(.system(size: 14))
            .lineSpacing(6)
            .padding(.vertical, 15)
            .padding(.horizontal, 18)
            .background {
                UnevenRoundedRectangle(bottomLeadingRadius: 16, bottomTrailingRadius: 16, topTrailingRadius: 16)
                    .fill(.aiCoBackgroundBlue)
            }
            .overlay {
                UnevenRoundedRectangle(bottomLeadingRadius: 16, bottomTrailingRadius: 16, topTrailingRadius: 16)
                    .strokeBorder(.accentGradient, lineWidth: 0.5)
            }
            .frame(maxWidth: 300, alignment: .leading)

            Spacer()
        }
    }
}
