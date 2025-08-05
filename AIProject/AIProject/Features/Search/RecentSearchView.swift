//
//  RecentSearchView.swift
//  AIProject
//
//  Created by 강대훈 on 8/5/25.
//

import SwiftUI

struct RecentSearchView: View {
    @ObservedObject var viewModel: SearchViewModel

    var body: some View {
        ScrollView {
            HStack {
                Text("최근 검색")
                    .padding(.vertical, 5)
                Spacer()
            }

            if viewModel.bookMarkCoins.isEmpty {
                HStack {
                    Text("검색 내역이 없어요.")
                        .font(.callout)
                        .foregroundStyle(.gray)
                    Spacer()
                }
            } else {
                ForEach(viewModel.bookMarkCoins) { coin in
                    HStack {
                        Image(systemName: "swift")
                        Text(coin.koreanName)
                            .bold()
                        Text(coin.id)
                            .font(.footnote)
                            .foregroundStyle(.gray)

                        Spacer()
                    }
                }
                .padding(.vertical, 5)
            }
        }
        .padding()
        .onAppear {
            viewModel.loadBookMarkCoins()
        }
    }
}

#Preview {
    RecentSearchView(viewModel: SearchViewModel())
}
