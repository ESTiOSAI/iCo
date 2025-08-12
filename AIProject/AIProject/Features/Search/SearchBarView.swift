//
//  SearchBarView.swift
//  AIProject
//
//  Created by 강대훈 on 8/11/25.
//

import SwiftUI

struct SearchBarView: View {
    @Binding var searchText: String

    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")

            TextField("코인 이름으로 검색하세요", text: $searchText)
                .padding(.horizontal, 8)

            if !searchText.isEmpty {
                Button {
                    searchText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .resizable()
                        .frame(width: 10, height: 10)
                }
                .foregroundStyle(.aiCoLabelSecondary)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 14)
        .background {
            RoundedRectangle(cornerRadius: 8)
                .fill(.aiCoBackground)
        }
        .padding(.horizontal, 16)
    }
}
