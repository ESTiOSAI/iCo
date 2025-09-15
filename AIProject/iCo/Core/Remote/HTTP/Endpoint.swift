//
//  Endpoint.swift
//  iCo
//
//  Created by 강대훈 on 9/15/25.
//

import Foundation

struct Endpoint {
    let path: URL
    let method: HTTPMethod
    let headers: [String: String]
    let body: Data?
}

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
}
