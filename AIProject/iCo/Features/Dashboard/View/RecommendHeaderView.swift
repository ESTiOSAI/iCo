//
//  RecommendHeaderView.swift
//  AIProject
//
//  Created by 강대훈 on 8/15/25.
//

import SwiftUI

struct RecommendHeaderView: View {
    var body: some View {
        VStack(spacing: 0) {
            HeaderView(heading: "대시보드", headingColor: .white)

            SubheaderView(
                imageName: "sparkles",
                subheading: "이런 코인은 어떠세요?",
                description: "회원님의 관심 코인을 기반으로 새로운 코인을 추천해드려요",
                imageColor: .white,
                fontColor: .white
            )
            
            Spacer()
        }
        .frame(height: CardConst.headerHeight)
    }
}

#Preview() {
    RecommendCoinView()
        .environmentObject(RecommendCoinViewModel())
}
