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
                    .foregroundStyle(.aiCoLabel)

                TextField("코인 이름으로 검색하세요", text: $searchText)
                    .autocorrectionDisabled()
                    .padding(.horizontal, 8)
                    .submitLabel(.search)
                    .font(.system(size: 14))
                    .focused($isFocused)
                    .onChange(of: isFocused) {
                        showCancel = isFocused
//                        Task {
//                            if isFocused {
//                                try? await Task.sleep(for: .milliseconds(50))
//                                withAnimation {
//                                    showCancel = true
//                                }
//                            } else {
//                                withAnimation(.snappy(duration: 0.2)) {
//                                    showCancel = false
//                                }
//                            }
//                        }
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
            
            Button {
                    isFocused = false
                    searchText = ""
            } label: {
                Text("취소")
                    .foregroundStyle(.aiCoNegative)
                    .font(.system(size: 13))
                    .padding(8)
            }
            .opacity(showCancel ? 1 : 0)
            .frame(width: showCancel ? 40 : 0, alignment: .trailing)
        }
        .onTapGesture {
            isFocused = true
        }
    }
}
