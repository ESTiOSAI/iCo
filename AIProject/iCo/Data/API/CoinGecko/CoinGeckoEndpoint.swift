//
//  CoinGeckoEndpoint.swift
//  iCo
//
//  Created by 강대훈 on 9/17/25.
//

import Foundation

enum CoinGeckoEndpoint {
    case bySymbol(symbols: [String], currency: String)
    case byID(ids: [String], currency: String)
}

extension CoinGeckoEndpoint: Requestable {
    var baseURL: String { "https://api.coingecko.com/api/v3" }
    var path: String { "/coins/markets" }
    var httpMethod: HTTPMethod { .get }
    var bodyParameters: Encodable? { nil }
    var headers: [String : String] { [:] }
    
    var queryParameters: Encodable? {
        switch self {
        case .bySymbol(let symbols, let currency):
            return ["vs_currency": currency.lowercased(), "symbols": formattedData(symbols: symbols)]
        case .byID(let ids, let currency):
            return ["vs_currency": currency.lowercased(), "ids": formattedData(symbols: ids)]
        }
    }
    
    private func formattedData(symbols: [String]) -> String {
        symbols
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() }
            .filter { !$0.isEmpty }
            .joined(separator: ",")
    }
}
