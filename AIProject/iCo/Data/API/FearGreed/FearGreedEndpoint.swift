//
//  FearGreedEndpoint.swift
//  iCo
//
//  Created by 강대훈 on 9/17/25.
//

import Foundation

enum FearGreedEndpoint {
    case main
}

extension FearGreedEndpoint: Requestable {
    var baseURL: String { "https://api.alternative.me" }
    var path: String { "/fng" }
    var httpMethod: HTTPMethod { .get }
    var queryParameters: Encodable? { nil }
    var bodyParameters: Encodable? { nil }
    var headers: [String : String] { [:] }
}
