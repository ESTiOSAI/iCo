//
//  ResponseStatus.swift
//  AIProject
//
//  Created by 장지현 on 8/12/25.
//

import SwiftUI

/// 네트워크 응답의 상태를 나타내는 열거형입니다.
///
/// - Cases:
///   - loading: 요청이 진행 중인 상태
///   - success: 요청이 성공적으로 완료된 상태
///   - failure: 요청이 실패한 상태. 연관 값으로 `NetworkError`를 포함
///   - cancel: 요청이 취소된 상태. 연관 값으로 `NetworkError`를 포함
enum ResponseStatus {
    case loading
    case success
    case failure(NetworkError)
    case cancel(NetworkError)
}
