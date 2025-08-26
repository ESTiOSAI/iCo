//
//  RecommendCardView.swift
//  AIProject
//
//  Created by 강대훈 on 8/1/25.
//

import SwiftUI

struct RecommendCardView: View {
    @EnvironmentObject var themeManager: ThemeManager
    
    let recommendCoin: RecommendCoin
    
    private func dynamicStatusColor(for type: RecommendCoin.TickerChangeType) -> Color {
        switch type {
        case .rise:
            return themeManager.selectedTheme.positiveColor
        case .even:
            return themeManager.selectedTheme.neutral
        case .fall:
            return themeManager.selectedTheme.negativeColor
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading) {
                CoinView(symbol: recommendCoin.id, size: 50)

                HStack(spacing: 10) {
                    Text(recommendCoin.name)
                        .font(.system(size: 17))
                        .bold()
                        .foregroundStyle(.aiCoLabel)

                    Text(recommendCoin.id)
                        .font(.system(size: 12))
                        .fontWeight(.semibold)
                        .foregroundStyle(.aiCoLabelSecondary)
                }
                .padding(.top, 4)

                HStack(spacing: 4) {
                    Text("현재가")
                        .font(.system(size: 14))
                        .foregroundStyle(.aiCoLabel)

                    Text(recommendCoin.tradePrice.formatKRW)
                        .font(.system(size: 14))
                        .bold()
                        .foregroundStyle(dynamicStatusColor(for: recommendCoin.changeType))
                }
                .padding(.top, 1)

                HStack(spacing: 4) {
                    Text("전일대비")
                        .font(.system(size: 14))
                        .foregroundStyle(.aiCoLabel)

                    HStack(spacing: 0) {
                        Group {
                            Text("\(recommendCoin.changeType.code)\(recommendCoin.changeRate.formatRate)")
                        }
                        .font(.system(size: 14))
                        .bold()
                        .foregroundStyle(dynamicStatusColor(for: recommendCoin.changeType))
                    }
                }
                .padding(.top, 0.2)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            VStack {
                Text(recommendCoin.comment.byCharWrapping)
                    .font(.system(size: 14))
                    .lineSpacing(6)
                    .foregroundStyle(.aiCoLabel)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .padding(.top, 32)
        }
        .padding(24)
        .background(
            ZStack {
                Rectangle().fill(.ultraThinMaterial)
                Color.aiCoBackgroundWhite.opacity(0.9)
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
            comment: "좋다!",
            coinID: "KRW-BTC",
            name: "비트코인",
            tradePrice: 1600,
            changeRate: 4.27,
            changeType: .rise
        )
    )
}


