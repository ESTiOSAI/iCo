//
//  BriefingSectionView.swift
//  AIProject
//
//  Created by kangho lee on 8/31/25.
//

import SwiftUI

struct BriefingSectionView: View {
    let briefing: PortfolioBriefingDTO
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("분석 결과")
                .font(.system(size: 14))
                .fontWeight(.semibold)
                .foregroundColor(Color(.iCoAccent))
            
            briefing.briefing
                .byCharWrapping
                .highlightTextForNumbersOperator()
                .font(AppFont.dynamic(size: 14))
                .lineSpacing(6)
            
            Spacer(minLength: 20)
            
            Text("전략 제안")
                .font(.system(size: 14))
                .fontWeight(.semibold)
                .foregroundColor(Color(.iCoAccent))
            
            briefing.strategy
                .byCharWrapping
                .highlightTextForNumbersOperator()
                .font(AppFont.dynamic(size: 14))
                .lineSpacing(6)
        }
    }
}
