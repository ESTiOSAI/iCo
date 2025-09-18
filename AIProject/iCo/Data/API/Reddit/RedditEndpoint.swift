//
//  RedditEndpoint.swift
//  iCo
//
//  Created by 강대훈 on 9/17/25.
//

import Foundation

enum RedditEndpoint {
    case main
}

extension RedditEndpoint: Requestable {
    var baseURL: String { "https://oauth.reddit.com" }
    var path: String { "/r/cryptocurrency/top.json" }
    var httpMethod: HTTPMethod { .get }
    var queryParameters: Encodable? { ["t": "day", "limit": "5"] }
    var bodyParameters: Encodable? { nil }
    var headers: [String : String] { [:] }
}
