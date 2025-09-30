//
//  RecomendationPlaceholderCardView.swift
//  AIProject
//
//  Created by Kitcat Seo on 8/21/25.
//

import SwiftUI

/// DefaultProgressView가 공중에 어색하게 떠있는 것을 개선하기 위해 만든 카드의 플레이스홀더뷰입니다.
struct RecomendationPlaceholderCardView: View {
    @Environment(\.horizontalSizeClass) private var hSizeClass
    
    /// 코인 추천 상태를 받는 속성
    var status: DefaultProgressView.Status
    /// 코인 추천 결과에 따른 메시지를 받는 속성
    var message: String
    /// 버튼 터치 시 실행할 액션을 받는 속성
    var action: () -> Void
    
    var body: some View {
        GeometryReader { geoProxy in
            ZStack {
                // 작은 화면에서는 카드 스택 배경 보여주기
                if hSizeClass == .compact {
                    CardStack(viewWidth: geoProxy.size.width)
                    .frame(maxWidth: geoProxy.size.width - (CardConst.cardInnerPadding * 2))
                }
                
                VStack {
                    DefaultProgressView(status: status, message: message) { action() }
                }
                .background(hSizeClass == .regular ?
                    ZStack {
                        Rectangle().fill(.ultraThinMaterial)
                        Color.aiCoBackgroundWhite.opacity(0.9)
                    }
                            : nil
                )
                .frame(maxWidth: hSizeClass == .regular ? 500 : .infinity)
                .frame(height: CardConst.cardHeight)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .overlay(
                    hSizeClass == .regular ? RoundedRectangle(cornerRadius: 20).strokeBorder(.defaultGradient, lineWidth: 0.5) : nil)
            }
            .frame(width: geoProxy.size.width)
        }
    }
    
    private struct CardStack: View {
        let viewWidth: CGFloat
        
        var body: some View {
            HStack(alignment: .bottom, spacing: .spacingS) {
                Group {
                    Color.aiCoBackgroundWhite.opacity(0.9)
                        .background(.ultraThinMaterial)
                        .frame(width: 100, height: CardConst.cardHeight * CardConst.cardHeightMultiplier)
                    
                    Color.aiCoBackgroundWhite.opacity(0.9)
                        .background(.ultraThinMaterial)
                        .frame(
                            width: viewWidth - (CardConst.cardInnerPadding * 2) - (.spacingXs * 2),
                            height: CardConst.cardHeight
                        )
                    
                    Color.aiCoBackgroundWhite.opacity(0.9)
                        .background(.ultraThinMaterial)
                        .frame(width: 100, height: CardConst.cardHeight * CardConst.cardHeightMultiplier)
                }
                .clipShape(RoundedRectangle(cornerRadius: 24))
                .overlay {
                    RoundedRectangle(cornerRadius: 24)
                        .strokeBorder(.defaultGradient, lineWidth: 0.5)
                }
            }
        }
    }
}

#Preview {
    RecomendationPlaceholderCardView(status: .cancel, message: "아이코가 추천할 코인을\n고르는 중이에요", action: { })
}
