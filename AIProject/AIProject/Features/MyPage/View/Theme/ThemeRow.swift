//
//  ThemeRow.swift
//  AIProject
//
//  Created by 강민지 on 8/8/25.
//

import SwiftUI

/// 테마 항목 하나를 나타내는 행 (선택 가능한 카드)
struct ThemeRow: View {
    /// 표시할 테마 이름
    let title: String
    /// 이 행이 나타내는 테마 값
    let theme: Theme
    /// 현재 해당 테마가 선택되었는지 여부
    let isSelected: Bool
    /// 사용자 탭 시 실행될 액션
    let onTap: () -> Void
    
    var body: some View {
        HStack {
            Text(title)
                .font(.body)
            
            Spacer()
            
            HStack(spacing: 0) {
                theme.positiveColor
                theme.negativeColor
            }
            .frame(width: 40, height: 20)
            .clipShape(RoundedRectangle(cornerRadius: 4))
        }
        .padding(20)
        .background {
            RoundedRectangle(cornerRadius: 10)
                .fill(isSelected ? Color.blue.opacity(0.1) : .aiCoBackground)
        }
        .overlay {
            RoundedRectangle(cornerRadius: 10)
                .stroke(isSelected ? Color.blue.opacity(0.1) : .aiCoBackground, lineWidth: 1)
        }
        .onTapGesture {
            onTap()
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 16)
    }
}
