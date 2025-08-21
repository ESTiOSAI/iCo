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
    @Environment(\.horizontalSizeClass) var hSizeClass
    @Environment(\.verticalSizeClass) var vSizeClass
    @EnvironmentObject var themeManager: ThemeManager
    @StateObject private var viewModel: InsightViewModel
    
    private var isPadLayout: Bool {
        hSizeClass == .regular && vSizeClass == .regular
    }
    
    init() {
        _viewModel = StateObject(wrappedValue: InsightViewModel())
    }
    
    var body: some View {
        SubheaderView(subheading: "새로운 소식들이 있어요")
            .padding(.bottom, 4)
        
        VStack(alignment: .leading, spacing: 20) {
            Text(String.aiGeneratedContentNotice)
                .font(.system(size: 11))
                .foregroundStyle(.aiCoNeutral)
                .lineSpacing(5)
            
            VStack(spacing: 16) {
                if isPadLayout {
                    HStack(spacing: 16) {
                        briefingView
                            .frame(height: 300)
                    }
                } else {
                    briefingView
                }
                
                FearGreedView()
                    .padding(.bottom, 30)
            }
        }
        .padding(.horizontal, 16)
    }
    
    @ViewBuilder
    private var briefingView: some View {
        // FIXME: ViewType enum + struct -> 프로퍼티를 enum 값에 따라 전달
        ReportSectionView(
            icon: "bitcoinsign.bank.building",
            title: "전반적인 시장의 분위기",
            state: viewModel.overall,
            onCancel: { viewModel.cancelOverall() },
            onRetry: { viewModel.retryOverall() }
        ) { value in
            Text(value.sentiment.rawValue)
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(value.sentiment.color(for: themeManager.selectedTheme))
        } content: { value in
            Text(AttributedString(value.summary.byCharWrapping))
        }
        
        ReportSectionView(
            icon: "shareplay",
            title: "주요 커뮤니티의 분위기",
            state: viewModel.community,
            onCancel: { viewModel.cancelCommunity() },
            onRetry: { viewModel.retryCommunity() }
        ) { value in
            Text(value.sentiment.rawValue)
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(value.sentiment.color(for: themeManager.selectedTheme))
        } content: { value in
            Text(AttributedString(value.summary.byCharWrapping))
        }
    }
}

#Preview {
    AIBriefingView()
}
