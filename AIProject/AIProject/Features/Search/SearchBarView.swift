//
//  SearchBarView.swift
//  AIProject
//
//  Created by 강대훈 on 8/11/25.
//

import SwiftUI

struct SearchBarView: View {
    @Binding var searchText: String
    @FocusState private var isFocused: Bool

    var body: some View {
        HStack(spacing: 10) {
            HStack {
                Image(systemName: "magnifyingglass")

                TextField("코인 이름으로 검색하세요", text: $searchText)
                    .padding(.horizontal, 8)
                    .focused($isFocused)
                    .submitLabel(.search)

                if !searchText.isEmpty {
                    CircleDeleteButton(fontSize: 9) {
                        searchText = ""
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 14)
            .shadow(radius: isFocused ? 1 : 0)
            .background {
                RoundedRectangle(cornerRadius: 15)
                    .fill(.aiCoBackground)
            }
            .animation(.snappy(duration: 0.2), value: isFocused)

            if isFocused {
                Button {
					// TODO: 취소 시에 검색 View 내리는 동작
                    withAnimation(.snappy) {
                        isFocused = false
                        searchText = ""
                    }
                } label: {
                    Text("취소")
                        .foregroundStyle(.aiCoNegative)
                        .font(.system(size: 13))
                        .padding(8)
                }
                .transition(.move(edge: .trailing).combined(with: .opacity))
            }
        }
    }
}
