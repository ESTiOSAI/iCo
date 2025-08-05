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
                Image(uiImage: recommendCoin.coinImage ?? UIImage())
                Text(recommendCoin.name)

                Spacer()

                Text(recommendCoin.coinID)
                    .foregroundStyle(.gray)
            }

            Text(recommendCoin.comment)
                .lineLimit(3)
                .padding(.vertical)

            Text(recommendCoin.tradePrice.formatKRW)
            Text(recommendCoin.changeRate.formatRate)
        }
        .padding()
        .frame(minHeight: 240)
        .background(.gray.opacity(0.1), in: RoundedRectangle(cornerRadius: 10))
    }
}

#Preview {
    RecommendCardView(
        recommendCoin: RecommendCoin(
            coinImage: UIImage(systemName: "swift"),
            comment: "좋다!",
            coinID: "KRW-BTC",
            name: "비트코인",
            tradePrice: 1600,
            changeRate: 4.27
        )
    )
}

