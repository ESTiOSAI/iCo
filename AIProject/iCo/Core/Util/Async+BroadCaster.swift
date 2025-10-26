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

public class AsyncStreamBroadcaster<Element> {
    private var continuations: [AsyncStream<Element>.Continuation] = []

    public func stream() -> AsyncStream<Element> {
        AsyncStream { continuation in
            continuations.append(continuation)
        }
    }

    @BroadCaster
    public func send(_ element: Element) async {
        for c in continuations {
            c.yield(element)
        }
    }

    public func finish() {
        for c in continuations {
            c.finish()
        }
    }
}
