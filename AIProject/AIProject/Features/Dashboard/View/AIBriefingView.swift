//
//  AIBriefingView.swift
//  AIProject
//
//  Created by 장지현 on 8/13/25.
//

import SwiftUI

/// 대시보드에서 AI 브리핑 섹션을 보여주는 뷰입니다.
///
/// 오늘의 인사이트, 커뮤니티 반응, 공포 탐욕 지수으로 구성합니다.
struct AIBriefingView: View {
    var body: some View {
        SubheaderView(subheading: "새로운 소식들이 있어요")
            .padding(.bottom, 4)
        
        VStack(spacing: 20) {
            Text(String.aiGeneratedContentNotice)
                .font(.system(size: 11))
                .foregroundStyle(.aiCoNeutral)
            
            VStack(spacing: 16) {
                TodayCoinInsightView()
                
                TodayCoinInsightView(isCommunity: true)
                
                FearGreedView()
                    .padding(.bottom, 30)
            }
        }
        .padding(.horizontal, 16)
    }
}

#Preview {
    AIBriefingView()
}
