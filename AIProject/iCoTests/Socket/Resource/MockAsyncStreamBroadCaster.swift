//
//  StateBroadCasterSpy.swift
//  iCo
//
//  Created by 강대훈 on 11/12/25.
//

@testable import iCo

final class MockAsyncStreamBroadCaster<Element>: AsyncStreamBroadcaster<Element> {
    var log: [Element] = []
    
    override func send(_ element: Element) async {
        log.append(element)
        await super.send(element)
    }
}
