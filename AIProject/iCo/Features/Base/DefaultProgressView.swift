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
    
    let status: Status
    
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
        status: Status,
        message: String,
        buttonAction: (() -> Void)? = nil
    ) {
        self.status = status
        self.message = message
        self.buttonAction = buttonAction
    }
    
    var body: some View {
        VStack(spacing: 0) {
            Group {
                switch status {
                case .loading:
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .aiCoAccent))
                        .scaleEffect(1.7) // 크기 살짝 키우기
                        .padding(16)
                        .background(.aiCoBackgroundAccent)
                case .failure:
                    Image(systemName: "xmark.octagon")
                        .font(.system(size: 35))
                        .foregroundStyle(.aiCoNeutral)
                        .padding(8)
                        .background(.aiCoBackgroundWhite)
                case .cancel:
                    Image(systemName: "exclamationmark.octagon")
                        .font(.system(size: 35))
                        .foregroundStyle(.aiCoNeutral)
                        .padding(8)
                        .background(.aiCoBackgroundWhite)
                }
            }
            .clipShape(.circle)
            .overlay {
                Circle()
                    .strokeBorder(status == .loading ? .accentGradient : .defaultGradient, lineWidth: 0.5)
            }
            .padding(.bottom, 18)
            
            Text(message)
                .font(.system(size: 14))
                .foregroundColor(.aiCoLabel)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .padding(.bottom, 10)
                .fixedSize(horizontal: false, vertical: true)
            
            switch status {
            case .loading:
                RoundedButton(title: "작업 취소", imageName: "xmark", action: buttonAction ?? {})
            case .cancel, .failure:
                RoundedButton(title: "다시 시도하기", imageName: "arrow.counterclockwise", action: buttonAction ?? {})
            }
            
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .padding()
    }
}

#Preview {
    DefaultProgressView(status: .loading, message: "아이코가 리포트를 작성하고 있어요", buttonAction: { print("Hi") })
    DefaultProgressView(status: .cancel, message: "작업이 취소됐어요", buttonAction: { print("Hi") })
    DefaultProgressView(status: .cancel, message: "데이터를 불러오지 못했어요\n잠시 후 다시 시도해 주세요", buttonAction: { print("Hi") })
}
