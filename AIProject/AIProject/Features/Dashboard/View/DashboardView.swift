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
    var body: some View {
        ScrollView {
            HeaderView(heading: "대시보드")
                .padding(.bottom, 16)
            
            DashboardSectionView(subheading: "이런 코인은 어떠세요?", description: "회원님의 관심 코인을 기반으로 새로운 코인을 추천해드려요") {
                RecommendCoinView()
            }
            
            AIBriefingView()
        }
    }
}

#Preview {
    DashboardView()
}
