//
//  Async+BroadCaster.swift
//  iCo
//
//  Created by 강대훈 on 10/26/25.
//

@globalActor
actor BroadCaster {
    static let shared = BroadCaster()
    
    private init() {}
}


/// AsyncStream의 다중 소비를 위해 만든 객체로 스트림 전파 수행
public class AsyncStreamBroadcaster<Element> {
    
    /// 구독할 continuation 값들
    private var continuations: [AsyncStream<Element>.Continuation] = []

    
    /// 구독 메서드로 stream을 반환
    /// - Returns: stream 반환
    public func stream() -> AsyncStream<Element> {
        AsyncStream { continuation in
            continuations.append(continuation)
        }
    }

    
    /// 전파할 메세지를 전송하고 구독자들에게 전파
    /// - Parameter element: 메세지
    @BroadCaster
    public func send(_ element: Element) async {
        for c in continuations {
            c.yield(element)
        }
    }

    
    /// 구독을 해제하고 스트림을 종료함
    public func finish() {
        for c in continuations {
            c.finish()
        }
    }
}
