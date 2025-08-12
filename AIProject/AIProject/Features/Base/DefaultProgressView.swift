//
//  DefaultProgressView.swift
//  AIProject
//
//  Created by 백현진 on 8/6/25.
//

import SwiftUI

/// 로딩, 실패, 취소 상태를 시각적으로 표시하는 공통 진행 상태 뷰입니다.
///
/// - Parameters:
///   - status: 현재 진행 상태(`loading`, `failure`, `cancel`)
///   - message: 상태와 함께 표시할 설명 문구
///   - buttonAction: 취소 또는 재시도 버튼의 액션. 기본값은 `nil`이며 버튼이 필요 없는 경우 생략 가능
///   - backgroundColor: 배경색. 기본값은 `.aiCoBackgroundWhite`
struct DefaultProgressView: View {
    
    /// 진행 상태를 나타내는 열거형입니다.
    ///
    /// - `loading`: 작업이 진행 중인 상태
    /// - `failure`: 작업이 실패한 상태.
    /// - `cancel`: 사용자가 작업을 취소한 상태.
    enum Status {
        case loading
        case failure
        case cancel
    }
    
    @State var status: Status
    
    /// 로딩 중에 표시할 메시지를 친근한 말투로 작성
    /// 예: "아이코가 보고서를 생성하고 있어요"
    let message: String
    
    /// 사용자가 작업을 취소하고자 할 때 호출되는 클로저
    ///
    /// 기본값으로 빈 클로저가 설정되어 있으므로,
    /// 이 뷰를 사용할 때 취소 버튼이 필요하지 않다면 생략 가능함.
    /// 예: `DefaultProgressView(message: "불러오는 중...")`
    let buttonAction: (() -> Void)?

    var backgroundColor: Color = .aiCoBackgroundWhite
    
    init(
        status: Status,
        message: String,
        buttonAction: (() -> Void)? = nil,
        backgroundColor: Color = .aiCoBackgroundWhite
    ) {
        self.status = status
        self.message = message
        self.buttonAction = buttonAction
        self.backgroundColor = backgroundColor
    }
    
    var body: some View {
        VStack(spacing: 12) {
            Group {
                switch status {
                case .loading:
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .aiCoAccent))
                        .scaleEffect(1.7) // 크기 살짝 키우기
                        .padding(16)
                case .failure:
                    Image(systemName: "xmark.octagon")
                        .font(.system(size: 35))
                        .foregroundStyle(.aiCoNeutral)
                        .frame(width: 44, height: 44)
                        .padding(5)
                case .cancel:
                    Image(systemName: "exclamationmark.octagon")
                        .font(.system(size: 35))
                        .foregroundStyle(.aiCoNeutral)
                        .frame(width: 44, height: 44)
                        .padding(5)
                }
            }
            .background(.aiCoAccent.opacity(0.05))
            .clipShape(.circle)
            .overlay {
                Circle()
                    .stroke(.accent, lineWidth: 0.5)
            }
            
            Text(message)
                .font(.system(size: 16))
                .foregroundColor(.aiCoLabel)
            
            switch status {
            case .loading:
                RoundedButton(title: "작업 취소", imageName: "xmark", action: buttonAction ?? {})
            case .cancel, .failure:
                RoundedButton(title: "다시 시도하기", imageName: "arrow.counterclockwise", action: buttonAction ?? {})
            }
            
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .padding()
        .background(backgroundColor)
    }
}

#Preview {
    DefaultProgressView(status: .failure, message: "아이코가 리포트를 작성하고 있어요", buttonAction: { print("Hi") })
}
