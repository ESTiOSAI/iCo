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
        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse, (200..<300) ~= httpResponse.statusCode else {
            throw NetworkError.invalidResponse
        }

        let modelData = try JSONDecoder().decode(T.self, from: data)
        return modelData
    }
    
    func requestWithBool(_ request: URLRequest) async throws -> Bool {
        let (_, response) = try await URLSession.shared.data(from: request.url!)
        
        if let httpResponse = response as? HTTPURLResponse, (200..<300) ~= httpResponse.statusCode {
            return true
        } else {
            return false
        }
    }
}
