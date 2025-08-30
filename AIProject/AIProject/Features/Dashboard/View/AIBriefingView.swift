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
    @State private var maxHeight: CGFloat = 0
    
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
                    }
                    .onPreferenceChange(HeightPreferenceKey.self) { value in
                        maxHeight = value
                    }
                } else {
                    VStack(spacing: 16) {
                        briefingView
                    }
                    .onPreferenceChange(HeightPreferenceKey.self) { value in
                        maxHeight = value
                    }
                }
                
                FearGreedView()
            }
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 30)
    }
    
    @ViewBuilder
    private var briefingView: some View {
        ForEach(viewModel.sectionDataSource) { data in
            ReportSectionView(
                data: data,
                trailing: {
                    Text($0.sentiment.rawValue)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle($0.sentiment.color(for: themeManager.selectedTheme))
                },
                content: { Text($0.summary.byCharWrapping) }
            )
            .frame(height: maxHeight)
        }
    }
}

#Preview {
    AIBriefingView()
        .environmentObject(ThemeManager())
}
