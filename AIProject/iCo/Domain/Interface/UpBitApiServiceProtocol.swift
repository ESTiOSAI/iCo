//
//  UpBitApiServiceProtocol.swift
//  AIProject
//
//  Created by kangho lee on 8/19/25.
//

import Foundation

protocol UpBitApiServiceProtocol {
    func fetchQuotes(id: String) async throws -> [TickerDTO]
}
