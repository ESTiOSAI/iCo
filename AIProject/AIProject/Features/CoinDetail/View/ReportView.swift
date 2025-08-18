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
    @StateObject var viewModel: ReportViewModel
    
    init(coin: Coin) {
        _viewModel = StateObject(wrappedValue: ReportViewModel(coin: coin))
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                Text(String.aiGeneratedContentNotice)
                    .font(.system(size: 11))
                    .foregroundStyle(.aiCoNeutral)
                
                ReportSectionView(
                    icon: "text.page.badge.magnifyingglass",
                    title: "한눈에 보는 \(viewModel.koreanName)",
                    state: viewModel.overview,
                    onCancel: { viewModel.cancelOverview() },
                    onRetry: { print("다시 시작 구현") }
                ) { value in
                    Text(value)
                }
                
                ReportSectionView(
                    icon: "calendar",
                    title: "주간 동향",
                    state: viewModel.weekly,
                    onCancel: { viewModel.cancelWeekly() },
                    onRetry: { print("다시 시작 구현") }
                ) { value in
                    Text(AttributedString(value))
                }
                
                ReportSectionView(
                    icon: "shareplay",
                    title: "오늘 시장의 분위기",
                    state: viewModel.today,
                    onCancel: { viewModel.cancelToday() },
                    onRetry: { print("다시 시작 구현") }
                ) { value in
                    Text(AttributedString(value))
                }
                
                if case .success = viewModel.today {
                    ReportNewsSectionView(articles: viewModel.news)
                        .padding(.bottom, 30)
                }
            }
        }
        .scrollIndicators(.hidden)
    }
}

#Preview {
    let sampleCoin = Coin(id: "KRW-BTC", koreanName: "비트코인")
    return ReportView(coin: sampleCoin).padding(.horizontal, 16)
}
