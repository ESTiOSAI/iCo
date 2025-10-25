//
//  Async+Timeout.swift
//  iCo
//
//  Created by kangho on 10/25/25.
//

import Foundation

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

public func performWithTimeout<T>(
    _ action: sending @escaping () async throws -> T,
    at timeout: Duration
) async throws -> T {
    return try await race(action) {
        try await Task.sleep(until: .now + timeout)
        throw URLError(.timedOut)
    }
}
