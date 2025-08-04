//
//  NetworkError.swift
//  AIProject
//
//  Created by 강대훈 on 7/30/25.
//

/// 네트워크 에러를 정의한 객체입니다.
enum NetworkError: Error {
    /// URL이 올바르지 않습니다.
    case invalidURL
    /// 웹소켓에서 에러가 발생했습니다.
    case webSocketError
    /// 응답이 올바르지 않습니다.
    case invalidResponse
	/// API Key가 올바르지 않습니다.
    case invalidAPIKey
    /// data가 올바르지 않습니다.
    case invalidData
}
