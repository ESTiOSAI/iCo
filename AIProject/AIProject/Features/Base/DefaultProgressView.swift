//
//  DefaultProgressView.swift
//  AIProject
//
//  Created by 백현진 on 8/6/25.
//

import SwiftUI

struct DefaultProgressView: View {
    let message: String
    let buttonAction: (() -> Void)?
    
    init(
        message: String,
        buttonAction: (() -> Void)? = nil
    ) {
        self.message = message
        self.buttonAction = buttonAction
    }
    
    var body: some View {
        VStack(spacing: 12) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .aiCoAccent))
                .scaleEffect(1.7) // 크기 살짝 키우기
                .padding(16)
                .background(.aiCoAccent.opacity(0.05))
                .clipShape(.circle)
                .overlay {
                    Circle()
                        .stroke(.accent, lineWidth: 0.5)
                }
            
            Text(message)
                .font(.system(size: 16))
                .foregroundColor(.aiCoLabel)
            
            if let buttonAction {
                RoundedButton(title: "작업취소", action: buttonAction)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .padding()
        .background(.ultraThinMaterial)
    }
}

#Preview {
    DefaultProgressView(message: "아이코가 리포트를 작성하고 있어요", buttonAction: { print("Hi") })
}
