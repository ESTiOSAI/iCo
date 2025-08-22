//
//  ReportView.swift
//  AIProject
//
//  Created by 장지현 on 7/31/25.
//

import SwiftUI

/// 코인에 대한 AI 분석 리포트를 보여주는 뷰입니다.
///
/// `ReportViewModel`을 통해 받아온 개요, 주간 동향, 오늘의 시장 분위기, 주요 뉴스를 섹션별로 표시합니다.
///
/// - Parameters:
///   - coin: 리포트를 보여줄 대상 코인
struct ReportView: View {
    @Environment(\.horizontalSizeClass) var hSizeClass
    @StateObject var viewModel: ReportViewModel
    
    init(coin: Coin) {
        _viewModel = StateObject(wrappedValue: ReportViewModel(coin: coin))
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if hSizeClass == .regular {
                Text("AI 리포트")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(.aiCoLabel)
            }
            
            Text(String.aiGeneratedContentNotice)
                .font(.system(size: 11))
                .foregroundStyle(.aiCoNeutral)
                .lineSpacing(5)
            
            ReportSectionView(
                icon: "text.page.badge.magnifyingglass",
                title: "한눈에 보는 \(viewModel.koreanName)",
                state: viewModel.overview,
                onCancel: { viewModel.cancelOverview() },
                onRetry: { viewModel.retryOverview() }
            ) { value in
                Text(value)
            }
            
            ReportSectionView(
                icon: "calendar",
                title: "주간 동향",
                state: viewModel.weekly,
                onCancel: { viewModel.cancelWeekly() },
                onRetry: { viewModel.retryWeekly() }
            ) { value in
                Text(value.byCharWrapping)
            }
            
            ReportSectionView(
                icon: "shareplay",
                title: "오늘 시장의 분위기",
                state: viewModel.today,
                onCancel: { viewModel.cancelToday() },
                onRetry: { viewModel.retryToday() }
            ) { value in
                Text(value.byCharWrapping)
            }
            
            if case .success = viewModel.today,
               !viewModel.news.allSatisfy({ $0.title.isEmpty && $0.summary.isEmpty }) {
                ReportNewsSectionView(articles: viewModel.news)
                    .padding(.bottom, 30)
            }
        }
    }
}

#Preview {
    let sampleCoin = Coin(id: "KRW-BTC", koreanName: "비트코인")
    return ScrollView { ReportView(coin: sampleCoin).padding(.horizontal, 16) }
}
