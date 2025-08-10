//
//  ThemeRow.swift
//  AIProject
//
//  Created by 강민지 on 8/8/25.
//

import SwiftUI

/// 테마 항목 하나를 나타내는 행 (선택 가능한 카드)
struct ThemeRow: View {
    let cornerRadius: CGFloat = 10
    
    /// 표시할 테마 이름
    let title: String
    /// 이 행이 나타내는 테마 값
    let theme: Theme
    /// 현재 해당 테마가 선택되었는지 여부
    let isSelected: Bool
    /// 사용자 탭 시 실행될 액션
    let action: () -> Void
    
    var body: some View {
        Button {
            action()
        } label: {
            HStack(spacing: 8) {
                Text(title)
                    .frame(height: 36)
                    .font(.system(size: 14, weight: !isSelected ? .regular : .medium))
                    .foregroundStyle(!isSelected ? .aiCoLabel : .aiCoAccent)
                
                Spacer()
                
                HStack(spacing: 0) {
                    theme.positiveColor
                    theme.negativeColor
                }
                .frame(width: 40, height: 20)
                .clipShape(RoundedRectangle(cornerRadius: 4))
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity)
            .background(!isSelected ? .aiCoBackground : .aiCoBackgroundAccent)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(!isSelected ? .default : .accent, lineWidth: 0.5)
            )
        }
    }
}

#Preview {
    VStack(spacing: 16) {
        ForEach(Theme.allCases, id: \.self) { theme in
            ThemeRow(
                title: theme.displayName,
                theme: theme,
                isSelected: theme == .basic,
                action: {}
            )
        }
    }
    .padding()
}
