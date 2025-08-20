//
//  Reconnectable+Model.swift
//  AIProject
//
//  Created by kangho lee on 8/17/25.
//

import Foundation

/// 재연결 정책. 지수적으로 재연결 인터벌을 증가시켜 서버 부하를 줄임
public struct ReconnectPolicy {
    public var base: Duration = .milliseconds(500)
    public var factor: Double = 2.0
    public var max: Duration = .seconds(10)
    public var jitter: Double = 0.3
    public var foregroundOnly: Bool = true
    public var maxAttemps = 3
    
    public init(base: Duration, factor: Double, max: Duration, jitter: Double, foregroundOnly: Bool) {
        self.base = base
        self.factor = factor
        self.max = max
        self.jitter = jitter
        self.foregroundOnly = foregroundOnly
    }
    
    public static func defaultPolicy() -> ReconnectPolicy {
        ReconnectPolicy(base: .milliseconds(500), factor: 2.0, max: .seconds(10), jitter: 0.3, foregroundOnly: true)
    }
}

public struct ExponentialBackoff {
    let policy: ReconnectPolicy
    private(set) var attempt: Int = 0

    mutating func next() -> Duration {
        defer { attempt += 1 }
        let expo = min(
            Double(policy.base.components.seconds) * pow(policy.factor, Double(attempt)),
            Double(policy.max.components.seconds)
        )
        let jitterRatio = 1.0 + (Double.random(in: 0...(policy.jitter)))
        let seconds = max(0.1, expo * jitterRatio)
        return .seconds(seconds)
    }

    mutating func reset() { attempt = 0 }
}

private extension Duration {
    var seconds: Double {
        Double(components.seconds) + Double(components.attoseconds) / 1e18
    }
}
