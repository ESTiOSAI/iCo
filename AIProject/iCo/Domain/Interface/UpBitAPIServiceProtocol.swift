//
//  UpBitApiServiceProtocol.swift
//  AIProject
//
//  Created by kangho lee on 8/19/25.
//

import Foundation

protocol UpBitAPIServiceProtocol {
    func fetchQuotes(id: String) async throws -> [TickerDTO]
    func fetchCandles(id: String, count: Int, to: Date?) async throws -> [MinuteCandleDTO]
}
