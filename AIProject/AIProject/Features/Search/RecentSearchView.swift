//
//  RecentSearchView.swift
//  AIProject
//
//  Created by 강대훈 on 8/5/25.
//

import SwiftUI

struct RecentSearchView: View {
    @ObservedObject var viewModel: SearchViewModel
    @State private var selectedCoin: Coin? = nil

    var body: some View {
        Group {
            if viewModel.recentSearchCoins.isEmpty {
                Text("검색 내역이 없어요")
                    .foregroundStyle(.aiCoLabelSecondary)
                    .font(.system(size: 14))
            } else {
                SearchListView(viewModel: viewModel, selectedCoin: $selectedCoin, isRecentSearch: true)
            }
        }
        .onAppear {
            viewModel.loadRecentSearchKeyword()
        }
    }
}

#Preview {
    RecentSearchView(viewModel: SearchViewModel())
}
