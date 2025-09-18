//
//  UpbitEndpoint.swift
//  iCo
//
//  Created by 강대훈 on 9/17/25.
//

import Foundation

enum UpbitEndpoint {
    case markets
    case ticker(currency: String)
    case ticks(id: String, count: Int)
    case quotes(id: String)
    case candles(id: String, count: Int, to: Date?)
}

extension UpbitEndpoint: Requestable {
    var baseURL: String { "https://api.upbit.com/v1" }
    var httpMethod: HTTPMethod { .get }
    var bodyParameters: Encodable? { nil }
    var headers: [String : String] { [:] }
    
    var path: String {
        switch self {
        case .markets:
            return "/market/all"
        case .ticker:
            return "/ticker/all"
        case .ticks:
            return "/trades/ticks"
        case .quotes:
            return "/ticker"
        case .candles:
            return "/candles/minutes/1"
        }
    }
    
    var queryParameters: Encodable? {
        switch self {
        case .markets:
            return nil
        case .ticker(let currency):
            return ["quote_currencies": currency]
        case .ticks(let id, let count):
            return ["market": id, "count": String(count)]
        case .quotes(let id):
            return ["markets": id]
        case .candles(let id, let count, let date):
            if let date {
                return ["market": id, "count": String(count), "to": date.asUpbitISO8601]
            } else {
                return ["market": id, "count": String(count)]
            }
        }
    }
}
