//
//  TodayCoinInsightView.swift
//  AIProject
//
//  Created by 장지현 on 8/6/25.
//

import SwiftUI

/// 오늘의 코인 시장과 커뮤니티 인사이트를 보여주는 뷰입니다.
///
/// `TodayCoinInsightViewModel`을 사용해 감정 분석 결과와 요약 정보를 표시합니다.
struct TodayCoinInsightView: View {
    @StateObject private var viewModel: TodayCoinInsightViewModel
    
    init() {
        _viewModel = StateObject(wrappedValue: TodayCoinInsightViewModel())
    }
    
    var body: some View {
        ReportSectionView(
            status: $viewModel.overviewStatus,
            imageName: "bitcoinsign.bank.building",
            title: "전반적인 시장의 분위기",
            sentiment: viewModel.overViewSentiment ?? nil,
            content: AttributedString(viewModel.overViewSummary)
        )
        
        ReportSectionView(
            status: $viewModel.communityStatus,
            imageName: "shareplay",
            title: "주요 커뮤니티의 분위기",
            sentiment: viewModel.communitySentiment ?? nil,
            content: AttributedString(viewModel.communitySummary)
        )
    }
}
