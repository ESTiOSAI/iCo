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
        VStack(spacing: 0) {
            HeaderView(heading: "테마 변경", showBackButton: true) {
                dismiss()
            }
            
            SubheaderView(subheading: "차트 색상 변경")
                .padding(.bottom, 20)
            
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
            
            Spacer(minLength: 0)
            
            /// 미리보기 차트 섹션
            VStack(alignment: .leading, spacing: 8) {
                Label {
                    Text("색상을 변경하면 아래 미리보기 색상이 변경됩니다.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                } icon: {
                    Image(systemName: "chart.xyaxis.line") // 또는 "waveform.path.ecgscope"로 골라봤습니다.
                        .font(.caption)
                        .symbolRenderingMode(.hierarchical)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal, 16)
                
                CandlestickPreviewView()
            }
            .transition(.opacity.combined(with: .scale))
            
            Spacer(minLength: 0)
        }
        .navigationBarBackButtonHidden()
    }
}

#Preview {
    ThemeView()
        .environmentObject(ThemeManager())
}
