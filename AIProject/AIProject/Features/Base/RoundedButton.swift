//
//  RoundedButton.swift
//  AIProject
//
//  Created by 백현진 on 8/6/25.
//

import SwiftUI

/// 버튼 터치 시 실행할 메서드
struct RoundedButton: View {
    let buttonHeight: CGFloat = 32
    
    let title: String
    var image: Image? = Image(systemName: "chevron.right")
    var foregroundColor: Color = .aiCoLabel
    var backgroundColor: Color = .aiCoBackground
    
    /// 버튼이 눌렸을 때 실행될 액션
    ///
    /// 외부에서 이 버튼을 사용할 때 실행하고자 하는 동작을 이 클로저로 전달
    /// 예: 버튼 클릭 시 네비게이션 이동, 토글, API 호출 등.
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Text(title)
                    .font(.system(size: 12)).bold()
                    .foregroundStyle(foregroundColor)
                
                if let image {
                    image
                        .resizable()
                        .scaledToFit()
                        .frame(height: 10)
                        .foregroundStyle(.aiCoLabelSecondary)
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 7)
            .background(
                RoundedRectangle(cornerRadius: buttonHeight / 2)
                    .fill(.aiCoBackground.opacity(0.1))
            )
            .overlay {
                RoundedRectangle(cornerRadius: buttonHeight / 2)
                    .stroke(.default, lineWidth: 0.5)
            }
        }
    }
}

#Preview {
    RoundedButton(title: "Hi", action: { print("Hi") })
}
