//
//  ChatInputView.swift
//  AIProject
//
//  Created by 강대훈 on 8/8/25.
//

import SwiftUI

struct ChatInputView: View {
    @ObservedObject var viewModel: ChatBotViewModel

    @FocusState private var isFocused: Bool

    var body: some View {
        HStack {
            TextField("무엇이든 물어보세요.", text: $viewModel.searchText, axis: .vertical)
                .lineLimit(1...3)
                .font(.system(size: 14))
                .foregroundStyle(.aiCoLabel)
                .focused($isFocused)

            Button {
                Task { await viewModel.sendMessage() }
            } label: {
                Image(systemName: "arrow.up")
                    .padding(10)
            }
            .frame(width: 30, height: 30)
            .background {
                Circle()
                    .fill(viewModel.isEditable ? .aiCoBackgroundAccent : .aiCoBackgroundWhite)
            }
            .onChange(of: viewModel.isTapped) {
                isFocused = false
            }
            .overlay {
                Circle()
                    .strokeBorder(viewModel.isEditable ? .accentGradient : .defaultGradient, lineWidth: 0.5)
            }
            .disabled(!viewModel.isEditable)
        }
        .onAppear {
            isFocused = true
        }
        .padding(.leading, 17)
        .padding(.trailing, 14)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 30)
                .fill(Color.aiCoBackgroundWhite)
        )
        .overlay {
            RoundedRectangle(cornerRadius: 30)
                .strokeBorder(.defaultGradient, lineWidth: 0.5)
        }
        .padding(.bottom, 10)
    }
}
