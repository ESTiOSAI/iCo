//
//  NetworkManager.swift
//  AIProject
//
//  Created by kangho lee on 7/29/25.
//

import Foundation

/// Network 통신을 담당하는 객체
final class NetworkClient {
    func request<T: Decodable>(url: URL) async throws -> T {
        let (data, _) = try await URLSession.shared.data(from: url)
        let modelData = try JSONDecoder().decode(T.self, from: data)
        return modelData
    }
}
