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
        VStack {
            HeaderView(heading: "검색")
                .padding(.vertical, 15)

            SearchBarView(searchText: $searchText)

            if searchText.isEmpty {
                SubheaderView(subheading: "최근 검색")
                    .padding(.top, 15)
            }

            Group {
                if searchText.isEmpty {
                    RecentSearchView(viewModel: viewModel)
                } else {
                    SearchResultView(viewModel: viewModel, searchText: searchText)
                }
            }
            .padding(.horizontal, 16)

            Spacer()
        }
        .onChange(of: searchText) {
            Task {
                await viewModel.sendKeyword(with: searchText)
            }
        }
    }
}

#Preview {
    NavigationStack {
        SearchView()
    }
}
