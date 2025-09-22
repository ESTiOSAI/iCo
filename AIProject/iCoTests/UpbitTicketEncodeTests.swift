//
//  UpbitTicketEncodeTests.swift
//  AIProjectTests
//
//  Created by kangho lee on 8/17/25.
//

import XCTest
@testable import iCo

final class UpbitTicketEncodeTests: XCTestCase {

    func test_tickerDTO_decoding() async throws {
        let data = Data(
            """
        [
            {
                "market": "KRW-AVNT",
                "trade_price": 3001.00000000,
                "change": "RISE"
            },
        ]
        """.utf8)
        let dto = try JSONDecoder().decode([TickerDTO].self, from: data)
        let value = dto.map { $0.toDomain() }.first
        XCTAssertEqual("KRW-AVNT", value?.id)
    }

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
        let target = SubscribeRequest.ticker(ticket: ticket, codes: coins)
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
