//
//  DashboardView.swift
//  AIProject
//
//  Created by kangho lee on 7/29/25.
//

import SwiftUI

struct DashboardView: View {
    
    var body: some View {
        ScrollView {
            HeaderView(heading: "대시보드")
                .padding(.bottom, 16)
            
            DashboardSectionView(subheading: "이런 코인은 어떠세요?", description: "회원님의 관심 코인을 기반으로 새로운 코인을 추천해드려요") {
                RecommendCoinView()
            }
            
            DashboardSectionView(subheading: "새로운 소식들이 있어요") {
                TodayCoinInsightView()
            }
            
            DashboardSectionView(subheading: "지금 주요 커뮤니티 분위기는") {
                TodayCoinInsightView(isCommunity: true)
            }
            
            DashboardSectionView(subheading: "공포 탐욕 지수", description: "투자 심리를 0~100 사이 수치로 나타낸 지표로, 0에 가까울수록 불안감으로 투자를 피하는 ‘공포’, 100에 가까울수록 낙관적으로 적극 매수하는 ‘탐욕’을 의미합니다.") {
                FearGreedView()
                    .padding()
            }
        }
    }
}

#Preview {
    DashboardView()
}
