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
        VStack {
            VStack(alignment: .leading) {
                AsyncImage(url: recommendCoin.imageURL) { image in
                    image
                        .resizable()
                        .frame(width: 40, height: 40)
                        .clipShape(Circle())
                        .overlay {
                            Circle()
                                .stroke(.default, lineWidth: 0.5)
                        }
                } placeholder: {
                    Text(String(recommendCoin.name.prefix(1)))
                        .font(.system(size: 14))
                        .foregroundStyle(.aiCoAccent)
                        .frame(width: 40, height: 40)
                        .overlay {
                            Circle()
                                .stroke(.default, lineWidth: 0.5)
                        }
                }

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
                        .foregroundStyle(recommendCoin.changeRate > 0 ? .aiCoPositive : .aiCoNegative) // TODO: 변동 없을때의 경우
                }
                .padding(.top, 1)

                HStack(spacing: 4) {
                    Text("전일대비")
                        .font(.system(size: 14))

                    HStack(spacing: 0) {
                        // TODO: 변동 없을때의 경우
                        Group {
                            Image(systemName: recommendCoin.changeRate > 0 ? "arrowtriangle.up.fill" : "arrowtriangle.down.fill")
                            Text(recommendCoin.changeRate.formatRate)
                        }
                        .font(.system(size: 14))
                        .bold()
                        .foregroundStyle(recommendCoin.changeRate > 0 ? .aiCoPositive : .aiCoNegative) // TODO: 변동 없을때의 경우
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Spacer()

            VStack {
                Text(recommendCoin.comment)
                    .foregroundStyle(.aiCoLabel)
                    .font(.system(size: 14))
            }
        }
        .padding(20)
        .frame(width: 280, height: 300)
        .background(.aiCoBackgroundWhite)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay {
            RoundedRectangle(cornerRadius: 20)
                .stroke(.accent, lineWidth: 0.5)
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
            changeRate: 4.27
        )
    )
}

