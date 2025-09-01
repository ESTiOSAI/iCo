//
//  FetchState.swift
//  AIProject
//
//  Created by 장지현 on 8/18/25.
//

import Foundation

/// 네트워크 데이터 요청의 상태를 표현하는 제네릭 열거형입니다.
///
/// 성공(`success`) 상태에서는 연관 값으로 결과 데이터를 함께 관리하여,
/// 이후 뷰나 로직에서 바로 활용할 수 있도록 제공합니다.
///
/// - Cases:
///   - loading: 데이터 요청이 진행 중인 상태
///   - success: 요청이 성공하여 결과 값을 반환한 상태
///   - cancel: 요청이 사용자 또는 시스템에 의해 취소된 상태. `NetworkError`를 포함
///   - failure: 요청이 실패한 상태. `NetworkError`를 포함
enum FetchState<Value> {
    case loading
    case success(Value)
    case cancel(NetworkError)
    case failure(NetworkError)
}

extension FetchState {
    var isLoading: Bool {
        if case .loading = self { return true }
        return false
    }
}
