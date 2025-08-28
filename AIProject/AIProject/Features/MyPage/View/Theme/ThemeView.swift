//
//  ThemeView.swift
//  AIProject
//
//  Created by 백현진 on 8/3/25.
//

import SwiftUI

/// 사용자가 테마를 선택할 수 있는 설정 뷰
struct ThemeView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack(alignment: .top) {
            ScrollView {
                VStack(spacing: 0) {
                    HeaderView(heading: "테마 변경", showBackButton: true) {
                        dismiss()
                        print("Back")
                    }
                    
                    SubheaderView(subheading: "차트 색상 변경")
                        .padding(.bottom, 16)
                    
                    VStack(spacing: 16) {
                        ForEach(Theme.allCases, id: \.self) { theme in
                            ThemeRow(
                                title: theme.displayName,
                                theme: theme,
                                isSelected: themeManager.selectedTheme == theme
                            ) {
                                themeManager.selectedTheme = theme
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .animation(.snappy, value: themeManager.selectedTheme)
                    .buttonStyle(.plain)
                }
                .padding(.bottom, 40)
                
                /// 미리보기 차트 섹션
                VStack(alignment: .leading, spacing: 16) {
                    SubheaderView(imageName: "chart.xyaxis.line", subheading: "차트 색상 미리보기", imageColor: .aiCoLabelSecondary)
                        .padding(.bottom, 4)
                    
                    CandlestickPreviewView()
                }
                .transition(.opacity.combined(with: .scale))
            }
            
            SafeAreaBackgroundView()
        }
        .navigationBarBackButtonHidden()
        .interactiveSwipeBackEnabled()
    }
}

#Preview {
    ThemeView()
        .environmentObject(ThemeManager())
}
