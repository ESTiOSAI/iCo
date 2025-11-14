//
//  Async+BroadCaster.swift
//  iCo
//
//  Created by 강대훈 on 10/26/25.
//

import Foundation

@globalActor
public actor BroadCaster {
    public static let shared = BroadCaster()
    
    private init() {}
}

/// AsyncStream의 다중 소비를 위해 만든 객체로 스트림 전파 수행
public class AsyncStreamBroadcaster<Element> {
    
    /// 구독할 continuation 값들
    private var continuations: [UUID: AsyncStream<Element>.Continuation] = [:]
    
    public init() {}
    
    /// 구독 메서드로 stream을 반환
    /// - Returns: stream 반환
    public func stream() -> AsyncStream<Element> {
        let id = UUID()
        
        return AsyncStream<Element> { continuation in
            continuation.onTermination = { [weak self] _ in
                guard let self = self else { return }
                self.finish(id: id)
            }
            
            continuations[id] = continuation
        }
    }

    
    /// 전파할 메세지를 전송하고 구독자들에게 전파
    /// - Parameter element: 메세지
    @BroadCaster
    public func send(_ element: Element) async {
        for (_, c) in continuations {
            c.yield(element)
        }
    }

    
    /// 전체 구독을 해제하고 스트림을 종료함
    public func finish() {
        for (_, c) in continuations {
            c.finish()
        }
    }
    
    /// 일부 구독을 해제함
    private func finish(id: UUID) {
        continuations[id] = nil
    }
}
