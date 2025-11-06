//
//  CoinInfoView.swift
//  iCo
//
//  Created by 지현 on 10/27/25.
//

import SwiftUI

struct CoinInfoView: View {
    @EnvironmentObject var themeManager: ThemeManager
    
    let recommendCoin: RecommendCoin
    var onCloseButtonTap: (() -> Void)? = nil
    
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
        VStack(spacing: 16) {
            HStack(alignment: .center, spacing: .spacing) {
                CoinView(symbol: recommendCoin.id, size: 50)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(recommendCoin.name)
                        .font(.ico19B)
                        .bold()
                        .foregroundStyle(.iCoLabel)
                    
                    Text(recommendCoin.id)
                        .font(.ico14Sb)
                        .fontWeight(.semibold)
                        .foregroundStyle(.iCoLabelSecondary)
                }
                
                Spacer()
                
                if let onCloseButtonTap {
                    RoundedButton(imageName: "xmark") {
                        onCloseButtonTap()
                    }
                }
            }
            
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 4) {
                        Text("현재가")
                            .font(.ico16)
                            .foregroundStyle(.iCoLabel)
                        
                        Text(recommendCoin.tradePrice.formatKRW)
                            .font(.ico16B)
                            .bold()
                            .foregroundStyle(dynamicStatusColor(for: recommendCoin.changeType))
                    }
                    
                    HStack(spacing: 4) {
                        Text("전일대비")
                            .font(.ico16)
                            .foregroundStyle(.iCoLabel)
                        
                        Group {
                            Text("\(recommendCoin.changeType.code)\(recommendCoin.changeRate.formatRate)")
                        }
                        .font(.ico16B)
                        .bold()
                        .foregroundStyle(dynamicStatusColor(for: recommendCoin.changeType))
                    }
                }
                
                Spacer()
                
                LineChartView(values: recommendCoin.candles, lineColor: dynamicStatusColor(for: recommendCoin.changeType))
                    .frame(width: 130, height: 40)
            }
        }
    }
}

#Preview {
    CoinInfoView(
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
        .environmentObject(ThemeManager())
}
