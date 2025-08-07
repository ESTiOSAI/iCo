//
//  NetworkError.swift
//  AIProject
//
//  Created by 강대훈 on 7/30/25.
//

/// 네트워크 에러를 정의한 객체입니다.
enum NetworkError: Error {
    /// 일반 네트워크 연결 오류입니다.
    case networkError(_ error: Error)
    /// 잘못된 URL 요청입니다.
    case invalidURL
    /// 웹소켓 통신 중 발생한 오류입니다.
    case webSocketError
    /// 유효하지 않은 응답을 수신한 경우입니다.
    case invalidResponse
    /// API 키가 유효하지 않거나 누락된 경우입니다.
    case invalidAPIKey
    /// API 호출 한도를 초과한 경우입니다.
    case quotaExceeded(_ statusCode: Int)
    /// 요청 URI가 너무 길어 서버가 처리할 수 없는 경우입니다.
    case uriTooLong(_ statusCode: Int)
    /// 서버가 유지보수 중이거나 일시적으로 사용할 수 없는 경우입니다.
    case serviceUnavilable(_ statusCode: Int)
    /// 서버 내부 오류(500번대 HTTP 응답 등)입니다.
    case serverError(_ statusCode: Int)
    /// 서버로부터 전달된 상태 코드와 오류 메시지를 포함한 오류입니다.
    case remoteError(_ statusCode: Int, _ errorData: String)
    /// 알 수 없는 상태 코드 기반의 오류입니다.
    case unknown(_ statusCode: Int)
}
