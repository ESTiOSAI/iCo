//
//  RelatedKeywordView.swift
//  AIProject
//
//  Created by 강대훈 on 8/5/25.
//

import SwiftUI

struct RelatedKeywordView: View {
    @ObservedObject var viewModel: SearchViewModel
    
    var body: some View {
        List {
            ForEach(viewModel.relatedCoins) { coin in
                HStack {
                    Image(systemName: "swift")
                    Text(coin.koreanName)
                    Text(coin.id)
                        .font(.footnote)
                        .foregroundStyle(.gray)
                    Spacer()
                }
                .onTapGesture {
                    viewModel.addRecentSearchKeyword(coin)
                }
            }
        }
    }
}

#Preview {
    RelatedKeywordView(viewModel: SearchViewModel())
}
