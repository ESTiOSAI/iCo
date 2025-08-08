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
    
    var body: some View {
        VStack {
            HeaderView(heading: "테마 변경")
                .padding(.top, 20)
                .padding(.bottom, 20)
            SubheaderView(subheading: "차트 색상 변경")
                .padding(.bottom, 20)
            
            ThemeRow(
                title: "기본",
                theme: .basic,
                isSelected: themeManager.selectedTheme == .basic
            ) {
                themeManager.selectedTheme = .basic
            }

            ThemeRow(
                title: "팝",
                theme: .pop,
                isSelected: themeManager.selectedTheme == .pop
            ) {
                themeManager.selectedTheme = .pop
            }
            
            ThemeRow(
                title: "고전",
                theme: .classic,
                isSelected: themeManager.selectedTheme == .classic
            ) {
                themeManager.selectedTheme = .classic
            }
            
            Spacer()
        }
    }
}

#Preview {
    ThemeView()
}
