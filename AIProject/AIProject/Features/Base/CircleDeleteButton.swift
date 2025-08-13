//
//  CircleDeleteButton.swift
//  AIProject
//
//  Created by 강대훈 on 8/13/25.
//

import SwiftUI

/// 삭제 버튼 공동 컴포넌트입니다.
struct CircleDeleteButton: View {
    /// 이미지의 폰트 사이즈입니다.
    let fontSize: CGFloat
    /// 버튼이 눌렸을 때 호출할 클로저입니다.
    var action: () -> Void

    var body: some View {
        Button {
            action()
        } label: {
            Image(systemName: "xmark")
                .font(.system(size: fontSize))
                .foregroundStyle(.aiCoLabelSecondary)
                .padding(5)
                .background {
                    Circle()
                        .fill(.aiCoBackgroundWhite)
                }
                .overlay {
                    Circle()
                        .stroke(Gradient.aiCoGradientStyle(.default), lineWidth: 0.5)
                }
        }
    }
}
