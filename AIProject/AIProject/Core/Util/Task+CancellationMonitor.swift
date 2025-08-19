//
//  Task+CancellationMonitor.swift
//  AIProject
//
//  Created by 장지현 on 8/18/25.
//

import Foundation

extension Task where Failure: Error {
    /// 해당 Task가 취소 계열 오류로 종료되면 즉시 `onCancel`을 MainActor에서 호출합니다.
    ///
    /// - Parameter onCancel: Task가 `CancellationError`, `URLError.cancelled`, `NetworkError.taskCancelled`
    ///   등 취소 오류로 종료되었을 때 실행할 클로저. 항상 `MainActor`에서 호출됩니다.
    /// - Returns: 감시용 Task 핸들. 필요 시 호출자가 직접 취소할 수 있습니다.
    @discardableResult
    func monitorCancellation(
        _ onCancel: @escaping @MainActor @Sendable () -> Void
    ) -> Task<Void, Never> {
        return Task<Void, Never> { @Sendable in
            let result: Result<Success, Failure> = await self.result
            if case .failure(let error) = result {
                if error.isTaskCancellation {
                    await onCancel()
                }
            }
        }
    }
}
