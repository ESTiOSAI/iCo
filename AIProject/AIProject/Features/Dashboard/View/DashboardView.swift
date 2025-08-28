//
//  DashboardView.swift
//  AIProject
//
//  Created by kangho lee on 7/29/25.
//

import SwiftUI

/// 메인 화면에 다양한 코인 관련 섹션을 보여주는 대시보드 뷰입니다.
///
/// 관심 코인 기반 추천, AI 브리핑으로 구성합니다.
struct DashboardView: View {
    @Environment(\.horizontalSizeClass) var hSizeClass
    
    var body: some View {
        let tempPadding: CGFloat = { hSizeClass == .regular ? 70 : 50 }()
        
        NavigationStack {
            ScrollView {
                ZStack(alignment: .top) {
                    LinearGradient(
                        colors: [.aiCoBackgroundGradientLight, .aiCoBackgroundGradientProminent],
                        startPoint: .topLeading,
                        endPoint: .bottom
                    )
                    .frame(height: CardConst.headerHeight + CardConst.headerContentSpacing + (CardConst.cardHeight / 2) + tempPadding)
                    
                    VStack {
                        RecommendCoinView()
                        AIBriefingView()
                    }
                    .padding(.top, tempPadding)
                }
            }
            .ignoresSafeArea(edges: .top)
            .scrollIndicators(.hidden)
        }
    }
}

#Preview {
    DashboardView()
        .environmentObject(ThemeManager())
        .environmentObject(RecommendCoinViewModel())
}
