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
    @State private var showCancel: Bool = false

    var body: some View {
        HStack(spacing: 10) {
            HStack {
                Image(systemName: "magnifyingglass")

                TextField("코인 이름으로 검색하세요", text: $searchText)
                    .padding(.horizontal, 8)
                    .focused($isFocused)
                    .submitLabel(.search)
                    .font(.system(size: 14))
                    .onChange(of: isFocused) {
                        if isFocused {
                            Task {
                                try await Task.sleep(for: .seconds(0.1))
                                await MainActor.run { showCancel = true }
                            }
                        }
                    }

                if !searchText.isEmpty {
                    CircleDeleteButton(fontSize: 9) {
                        searchText = ""
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 14)
            .background {
                RoundedRectangle(cornerRadius: 15)
                    .fill(showCancel ? .aiCoBackgroundBlue : .aiCoBackground)
            }
            .overlay {
                RoundedRectangle(cornerRadius: 15)
                    .strokeBorder(showCancel ? .accentGradient : .defaultGradient, lineWidth: 0.5)
            }
            .animation(.snappy(duration: 0.1), value: showCancel)

            if showCancel {
                Button {
                    withAnimation(.snappy) {
                        showCancel = false
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
