//
//  EmptySearchResultView.swift
//  AIProject
//
//  Created by 강대훈 on 8/6/25.
//

import SwiftUI

struct EmptySearchResultView: View {
    let searchText: String

    var body: some View {
        VStack {
            Image(systemName: "magnifyingglass")
                .resizable()
                .frame(width: 70, height: 70)
            Text("\"\(searchText)\"에 대한 결과 없음")
                .font(.system(size: 25))
                .fontWeight(.bold)
                .padding(.vertical, 3)
            Text("맞춤법을 확인하거나 새로운 검색을 시도하십시오.")
                .foregroundStyle(.gray)
        }
    }
}

#Preview {
    EmptySearchResultView(searchText: "비트")
}
