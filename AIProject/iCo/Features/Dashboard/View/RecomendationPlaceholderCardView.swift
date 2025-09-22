//
//  RecomendationPlaceholderCardView.swift
//  AIProject
//
//  Created by Kitcat Seo on 8/21/25.
//

import SwiftUI

/// DefaultProgressView가 공중에 어색하게 떠있는 것을 개선하기 위해 만든 카드의 플레이스홀더뷰
/// 사실 플레이스홀더 뷰를 메인으로 띄우고, 네트워크 로드가 완료되면 내부 컨텐츠만 바꾸는 방식으로 가고 싶은데... 추후에 변경하는 것으로...
struct RecomendationPlaceholderCardView: View {
    @Environment(\.horizontalSizeClass) var hSizeClass
    
    var status: DefaultProgressView.Status
    var message: String
    var action: () -> Void
    
    var body: some View {
        GeometryReader { geoProxy in
            ZStack {
                if hSizeClass == .compact {
                    HStack(alignment: .bottom, spacing: 16) {
                        Group {
                            Color.aiCoBackgroundWhite.opacity(0.9)
                                .background(.ultraThinMaterial)
                                .frame(width: 100, height: CardConst.cardHeight * CardConst.cardHeightMultiplier)
                            
                            Color.aiCoBackgroundWhite.opacity(0.9)
                                .background(.ultraThinMaterial)
                                .frame(
                                    width: geoProxy.size.width - (CardConst.cardInnerPadding * 2) - (.spacing * 2),
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
                .frame(maxWidth: hSizeClass == .regular ? 400 : .infinity)
                .frame(height: CardConst.cardHeight)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .overlay(
                    hSizeClass == .regular ? RoundedRectangle(cornerRadius: 20).strokeBorder(.defaultGradient, lineWidth: 0.5) : nil)
            }
            .frame(width: geoProxy.size.width)
        }
    }
}

#Preview {
    RecomendationPlaceholderCardView(status: .cancel, message: "아이코가 추천할 코인을\n고르는 중이에요", action: { })
}
