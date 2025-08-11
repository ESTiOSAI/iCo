//
//  ChatInputView.swift
//  AIProject
//
//  Created by 강대훈 on 8/8/25.
//

import SwiftUI

struct ChatInputView: View {
    @ObservedObject var viewModel: ChatBotViewModel

    let isFocused: FocusState<Bool>.Binding

    var body: some View {
        HStack {
            TextField("무엇이든 물어보세요.", text: $viewModel.searchText)
                .font(.system(size: 14))
                .foregroundStyle(.aiCoLabelSecondary)
                .focused(isFocused)

            Button {
                Task { await viewModel.sendMessage() }
            } label: {
                Image(systemName: "arrow.up")
                    .padding(10)
            }
            .background {
                Circle()
                    .fill(viewModel.isEditable ? .aiCoBackgroundAccent : .aiCoBackgroundWhite)
            }
            .overlay {
                Circle()
                    .stroke(Gradient.aiCoGradientStyle(viewModel.isEditable ? .accent : .default), lineWidth: 0.5)
            }
            .disabled(!viewModel.isEditable)
        }
        .padding(.leading, 17)
        .padding(.trailing, 14)
        .padding(.vertical, 10)
        .overlay {
            RoundedRectangle(cornerRadius: 30)
                .stroke(Gradient.aiCoGradientStyle(.default), lineWidth: 0.5)
        }
        .padding(.horizontal)
        .padding(.bottom, 10)
    }
}
