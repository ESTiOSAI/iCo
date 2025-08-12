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
            Text("검색 결과가 없습니다")
                .font(.system(size: 13))
                .foregroundStyle(.aiCoLabelSecondary)
        } else {
            SearchListView(viewModel: viewModel, selectedCoin: $selectedCoin, isRecentSearch: false)
        }
    }
}

#Preview {
    SearchResultView(viewModel: SearchViewModel(), searchText: "비트")
}
