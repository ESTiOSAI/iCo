//
//  UpbitTicketEncodeTests.swift
//  AIProjectTests
//
//  Created by kangho lee on 8/17/25.
//

import XCTest
@testable import AIProject

final class UpbitTicketEncodeTests: XCTestCase {

    func test_ticket_encoding() throws {
        let ticket = UUID().uuidString
        let coins = ["KRW-BTC", "KRW-ETH"]
        
        let _ = Data("""
        [
          {
            "ticket": "\(ticket)"
          },
          {
            "type": "ticker",
            "codes": \(coins)
          },
          {
            "format": "DEFAULT"
          }
        ]
""".utf8)
        let target = SubscribeRequest.ticker(ticket: ticket, codes: coins).components()
        let encoder = JSONEncoder()
        let model = try encoder.encode(target)
        
        let result = try JSONSerialization.jsonObject(with: model, options: []) as! [[String: Any]]
        
        XCTAssertEqual(3, result.count)
        
        let ticketValue = result.compactMap { $0["ticket"] as? String }.first!
        XCTAssertEqual(ticketValue, ticket)
        
        let formatValue = result.compactMap { $0["format"] as? String }.first!
        XCTAssertEqual(formatValue, "DEFAULT")
        
        let body = result.first(where: { $0["type"] != nil })!
        XCTAssertEqual(body["type"] as! String, "ticker")
        XCTAssertEqual(body["codes"] as! [String], coins)
    }
}
