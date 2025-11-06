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
        VStack(alignment: .leading, spacing: 0) {
            CoinInfoView(recommendCoin: recommendCoin)
            
            Spacer()
            
            Text(recommendCoin.comment.byCharWrapping)
                .font(.ico15)
                .lineSpacing(6)
                .foregroundStyle(.iCoLabel)
        }
        .padding(24)
        .background(
            ZStack {
                Rectangle().fill(.ultraThinMaterial)
                Color.iCoBackgroundWhite.opacity(0.9)
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .overlay {
            RoundedRectangle(cornerRadius: 24)
                .strokeBorder(.defaultGradient, lineWidth: 0.5)
        }
    }
}

#Preview {
    RecommendCardView(
        recommendCoin: RecommendCoin(
            imageURL: nil,
            comment: "펏지펭귄은 활발한 커뮤니티와 밈 기반의 인기 덕분에 최근 주목받고 있어요. 소액으로 재미있게 투자하기 좋고, 성장 가능성도 보여 기대돼요. 소액으로 재미있게 투자하기 좋고, 성장 가능성도 보여 기대돼요.",
            coinID: "BTC",
            name: "월드리버티파이낸셜유에스디",
            tradePrice: 1600,
            changeRate: 4.27,
            changeType: .rise,
            candles: [1.0, 3.0, 2.0, 6.0, 5.0, 3.0, 7.0, 9.0, 6.0, 10.0]
        )
    )
}


