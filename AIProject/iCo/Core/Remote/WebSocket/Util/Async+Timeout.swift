//
//  Async+Timeout.swift
//  iCo
//
//  Created by kangho on 10/25/25.
//

import Foundation


/// 두 클로저 중 먼저 완료되는 클로저만 실행하고 나머지는 취소
/// - Parameters:
/// - Returns: 먼저 완료되는 클로저 실행
public func race<T>(
    _ lhs: sending @escaping () async throws -> T,
    _ rhs: sending @escaping () async throws -> T
) async throws -> T {
    return try await withThrowingTaskGroup(of: T.self) { group in
        group.addTask { try await lhs() }
        group.addTask { try await rhs() }
        
        defer { group.cancelAll() }
        
        return try await group.next()!
    }
}


/// async 작업에 timeout을 줌
/// - Parameters:
///   - action: 수행할 비동기 클로저
///   - timeout: 타임아웃 duration
/// - Throws: 타임아웃 에러 또는 작업에서 발생한 에러
/// - Returns: 비동기 작업 결과값
public func performWithTimeout<T>(
    _ action: sending @escaping () async throws -> T,
    at timeout: Duration
) async throws -> T {
    return try await race(action) {
        try await Task.sleep(until: .now + timeout)
        throw URLError(.timedOut)
    }
}
