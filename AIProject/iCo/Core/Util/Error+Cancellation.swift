//
//  Error+Cancellation.swift
//  AIProject
//
//  Created by 장지현 on 8/18/25.
//

import Foundation

extension Error {
    /// 현재 오류가 작업 취소(`CancellationError`, `URLError.cancelled`, `NetworkError.taskCancelled`)에 해당하는지 여부입니다.
    ///
    /// - Returns: 작업이 취소된 경우 `true`, 그렇지 않으면 `false`
    var isTaskCancellation: Bool {
        if self is CancellationError { return true }

        if let urlErr = self as? URLError, urlErr.code == .cancelled { return true }

        if let ne = self as? NetworkError {
            switch ne {
            case .taskCancelled:
                return true
            default:
                return false
            }
        }
        return false
    }
}
