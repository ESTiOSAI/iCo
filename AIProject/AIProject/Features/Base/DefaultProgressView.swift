//
//  DefaultProgressView.swift
//  AIProject
//
//  Created by 백현진 on 8/6/25.
//

import SwiftUI

struct DefaultProgressView: View {
    /// 로딩 중에 표시할 메시지를 친근한 말투로 작성
    /// 예: "아이코가 보고서를 생성하고 있어요"
    let message: String
    
    /// 사용자가 작업을 취소하고자 할 때 호출되는 클로저
    ///
    /// 기본값으로 빈 클로저가 설정되어 있으므로,
    /// 이 뷰를 사용할 때 취소 버튼이 필요하지 않다면 생략 가능함.
    /// 예: `DefaultProgressView(message: "불러오는 중...")`
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
