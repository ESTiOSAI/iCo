//
//  RecommendCardView.swift
//  AIProject
//
//  Created by 강대훈 on 8/1/25.
//

import SwiftUI

struct RecommendCardView: View {
    let recommendCoin: RecommendCoin
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Image(systemName: "swift")
                Text("Hyperliquid")

                Spacer()

                Text("HYPE")
                    .foregroundStyle(.gray)
            }

            Text("2025년 상반기 동안 높은 성과를 보여주셔서 감사합니다. 오늘도 화이팅!!")
                .lineLimit(3)
                .padding(.vertical)

            Text("현재가 1,333")
            Text("전일대비 3.00%")
        }
        .padding()
        .background(.gray.opacity(0.1), in: RoundedRectangle(cornerRadius: 10))
    }
}

#Preview {
    RecommendCardView(recommendCoin: RecommendCoin(comment: "좋다", coinID: "KRW-BTC"))
}
