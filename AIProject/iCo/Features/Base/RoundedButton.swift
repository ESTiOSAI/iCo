//
//  RoundedButton.swift
//  AIProject
//
//  Created by 백현진 on 8/6/25.
//

import SwiftUI

struct RoundedButton: View {
    @State private var isRotated: Bool = false

    var title: String?
    var imageName: String?
    var foregroundColor: Color?
    var rotatingAnimation: Bool = false
    
    /// 버튼이 눌렸을 때 실행될 액션
    ///
    /// 외부에서 이 버튼을 사용할 때 실행하고자 하는 동작을 이 클로저로 전달
    /// 예: 버튼 클릭 시 네비게이션 이동, 토글, API 호출 등.
    var action: (() -> Void)
    
    var body: some View {
        Button {
            action()
            if rotatingAnimation {
                isRotated.toggle()
            }
        } label: {
            HStack(spacing: 4) {
                if let title {
                    Text(title)
                        .font(.ico11)
                        .tint(foregroundColor ?? .iCoLabel)
                }
                
                if let imageName {
                    Image(systemName: imageName)
                        .font(.ico10)
                        .tint(foregroundColor ?? .iCoLabelSecondary)
                        .rotation3DEffect(
                            .degrees(isRotated ? 180 : 0),
                            axis: (x: 1, y: 0, z: 0) // Y축 기준 회전
                        )
                        .animation(.smooth, value: isRotated)
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 7)
            .frame(width: title != nil ? nil : 24, height: title != nil ? nil : 24)
            .background(
                Capsule()
                    .fill(.iCoBackgroundWhite)
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
        RoundedButton(title: "With Image", imageName: "xmark", action: { })
            .disabled(true)
        RoundedButton(title: "Text Only", imageName: nil, action: { })
        RoundedButton(title: nil, imageName: "xmark", action: { })
        RoundedButton(title: "확장", imageName: "chevron.down", rotatingAnimation: true, action: { })
    }
    .padding()
    .background(.iCoBackground)
}
