//
//  RoundedButton.swift
//  AIProject
//
//  Created by 백현진 on 8/6/25.
//

import SwiftUI

struct RoundedButton: View {
    var title: String?
    var imageName: String?
    var foregroundColor: Color?
    
    /// 버튼이 눌렸을 때 실행될 액션
    ///
    /// 외부에서 이 버튼을 사용할 때 실행하고자 하는 동작을 이 클로저로 전달
    /// 예: 버튼 클릭 시 네비게이션 이동, 토글, API 호출 등.
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                if let title {
                    Text(title)
                        .font(.system(size: 12, weight: .regular))
                        .tint(foregroundColor ?? .aiCoLabel)
                }
                
                if let imageName {
                    Image(systemName: imageName)
                        .font(.system(size: 10))
                        .tint(foregroundColor ?? .aiCoLabel)
                        
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 7)
            .frame(width: title != nil ? nil : 24, height: title != nil ? nil : 24)
            .background(
                Capsule()
                    .fill(.aiCoBackgroundWhite)
            )
            .overlay {
                Capsule()
                    .strokeBorder(.defaultGradient, lineWidth: 0.5)
            }
        }
    }
}

#Preview {
    VStack {
        RoundedButton(title: "With Image", imageName: "xmark", action: { dummyAction() })
            .disabled(true)
        RoundedButton(title: "Text Only", imageName: nil, action: { dummyAction() })
        RoundedButton(title: nil, imageName: "xmark", action: { dummyAction() })
    }
    .padding()
    .background(.aiCoBackground)
}
