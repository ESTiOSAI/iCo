//
//  RoundedButton.swift
//  AIProject
//
//  Created by 백현진 on 8/6/25.
//

import SwiftUI

struct RoundedButton: View {
    let title: String
    var imageName: String? = "chevron.right"
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
                        .font(.system(size: 12, weight: .regular))
                        .foregroundStyle(foregroundColor)
                
                if let imageName {
                    Image(systemName: imageName)
                        .font(.system(size: 10))
                        .foregroundStyle(.aiCoLabelSecondary)
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 7)
            .background(
                Capsule()
                    .fill(.aiCoBackgroundWhite)
            )
            .overlay {
                Capsule()
                    .stroke(.default, lineWidth: 0.5)
            }
        }
    }
}

#Preview {
    VStack {
        RoundedButton(title: "With Image", action: { dummyAction() })
        RoundedButton(title: "Text Only", imageName: nil, action: { dummyAction() })
    }
    .padding()
    .background(.aiCoBackground)
}
