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
        ScrollView {
            HStack {
                Text("최근 검색")
                    .padding(.vertical, 5)
                Spacer()
            }

            if viewModel.recentSearchCoins.isEmpty {
                HStack {
                    Text("검색 내역이 없어요.")
                        .font(.system(size: 15))
                        .foregroundStyle(.gray)
                    Spacer()
                }
            } else {
                RecentSearchListView(viewModel: viewModel, selectedCoin: $selectedCoin)
            }
        }
        .padding()
        .onAppear {
            viewModel.loadRecentSearchKeyword()
        }
    }
}

#Preview {
    RecentSearchView(viewModel: SearchViewModel())
}
