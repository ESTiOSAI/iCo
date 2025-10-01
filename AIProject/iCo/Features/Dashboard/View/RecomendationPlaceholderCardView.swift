//
//  RecomendationPlaceholderCardView.swift
//  AIProject
//
//  Created by Kitcat Seo on 8/21/25.
//

import SwiftUI

/// DefaultProgressView가 공중에 어색하게 떠있는 것을 개선하기 위해 만든 카드의 플레이스홀더뷰입니다.
struct RecomendationPlaceholderCardView: View {
    /// 코인 추천 상태를 받는 속성
    let status: DefaultProgressView.Status
    /// 코인 추천 결과에 따른 메시지를 받는 속성
    let message: String
    /// 버튼 터치 시 실행할 액션을 받는 속성
    let action: () -> Void
    
    var body: some View {
        GeometryReader { geoProxy in
            DefaultProgressView(status: status, message: message) { action() }
                .background {
                    Background(viewWidth: geoProxy.size.width)
                }
        }
    }
    
    /// horizontalSizeClass에 따라 배경에 카드 스택을 보여줄지 하나의 카드만 보여줄지를 결정하는 구조체입니다.
    /// 카드는 크기만 변경되므로 구조체로 만들어 재사용했습니다.
    private struct Background: View {
        @Environment(\.horizontalSizeClass) var hSizeClass
        
        let viewWidth: CGFloat
        let smallCardHeight = CardConst.cardHeight * CardConst.cardHeightMultiplier
        
        var body: some View {
            HStack(alignment: .bottom, spacing: .spacingSmall) {
                Group {
                    if hSizeClass == .compact {
                        Card()
                            .frame(width: 100, height: smallCardHeight)
                    }
                    
                    Card()
                        .frame(
                            width: viewWidth - (CardConst.cardInnerPadding * 2) - (.spacingXSmall * 2),
                            height: CardConst.cardHeight
                        )
                        .frame(maxWidth: hSizeClass == .compact ? .infinity : 500)
                    
                    if hSizeClass == .compact {
                        Card()
                            .frame(width: 100, height: smallCardHeight)
                    }
                }
            }
        }
    }
    
    private struct Card: View {
        var body: some View {
            Color.aiCoBackgroundWhite.opacity(0.9)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 24))
                .overlay {
                    RoundedRectangle(cornerRadius: 24)
                        .strokeBorder(.defaultGradient, lineWidth: 0.5)
                }
        }
    }
}

#Preview {
    RecomendationPlaceholderCardView(status: .cancel, message: "아이코가 추천할 코인을\n고르는 중이에요", action: { })
}
