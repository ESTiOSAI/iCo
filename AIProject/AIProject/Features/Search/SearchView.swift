//
//  SearchView.swift
//  AIProject
//
//  Created by 강대훈 on 8/5/25.
//

import SwiftUI

struct SearchView: View {
    @State private var searchText: String = ""
    @StateObject private var viewModel = SearchViewModel()

    var body: some View {
        NavigationStack {
            if searchText.isEmpty {
                RecentSearchView(viewModel: viewModel)
            } else {
                SearchResultView(viewModel: viewModel, searchText: searchText)
            }
        }
        .searchable(text: $searchText, prompt: "코인 이름으로 검색하세요")
        .onChange(of: searchText) {
            Task {
                await viewModel.sendKeyword(with: searchText)
            }
        }
    }
}

#Preview {
    SearchView()
}
