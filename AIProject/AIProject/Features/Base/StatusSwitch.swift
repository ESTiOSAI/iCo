//
//  StatusSwitch.swift
//  AIProject
//
//  Created by 장지현 on 8/13/25.
//

import SwiftUI

/// `ResponseStatus` 값에 따라 다른 뷰를 표시하는 상태 전환 뷰입니다.
///
/// 로딩, 성공, 실패, 취소 상태에 따라 각각 적절한 화면을 보여줍니다.
/// - 로딩, 실패, 취소 상태에서는 `DefaultProgressView`를 사용해 상태 메시지를 표시합니다.
/// - 성공 상태에서는 `success` 클로저를 통해 전달된 뷰를 표시합니다.
///
/// - Parameters:
///   - status: 현재 응답 상태(`ResponseStatus`)
///   - backgroundColor: 상태 표시 뷰의 배경색
///   - success: 성공 시 렌더링할 뷰를 반환하는 클로저
struct StatusSwitch<Success: View>: View {
    let status: ResponseStatus
    let backgroundColor: Color
    @ViewBuilder var success: () -> Success

    var body: some View {
        switch status {
        case .loading:
                .frame(height: 300)
            DefaultProgressView(status: .loading, message: "아이코가 리포트를 작성하고 있어요")
        case .success:
            success()
        case .failure(let networkError):
                .frame(height: 300)
            DefaultProgressView(status: .failure, message: networkError.localizedDescription)
        case .cancel(let networkError):
                .frame(height: 300)
            DefaultProgressView(status: .cancel, message: networkError.localizedDescription)
        }
    }
}
