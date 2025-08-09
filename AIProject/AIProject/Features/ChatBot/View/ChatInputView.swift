//
//  ChatInputView.swift
//  AIProject
//
//  Created by 강대훈 on 8/8/25.
//

import SwiftUI

struct ChatInputView: View {
    @ObservedObject var viewModel: ChatBotViewModel

    @State var searchText: String = ""

    let isFocused: FocusState<Bool>.Binding

    var body: some View {
        HStack {
            TextField("무엇이든 물어보세요.", text: $searchText)
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .cornerRadius(20)
                .focused(isFocused)
                .disabled(!viewModel.isEditable)

            Button {
                let tempText = searchText
                searchText = ""
                Task { await viewModel.sendMessage(with: tempText) }
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
