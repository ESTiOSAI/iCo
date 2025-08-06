//
//  RelatedKeywordView.swift
//  AIProject
//
//  Created by 강대훈 on 8/5/25.
//

import SwiftUI

struct SearchResultView: View {
    @ObservedObject var viewModel: SearchViewModel
    @State private var selectedCoin: Coin? = nil
    
    let searchText: String

    var body: some View {
        if viewModel.relatedCoins.isEmpty {
            EmptySearchResultView(searchText: searchText)
        } else {
            SearchResultListView(viewModel: viewModel, selectedCoin: $selectedCoin)
        }
    }
}

#Preview {
    SearchResultView(viewModel: SearchViewModel(), searchText: "비트")
}
