//
//  DecodingError.swift
//  AIProject
//
//  Created by 장지현 on 8/7/25.
//

import Foundation

/// JSON 디코딩 과정에서 발생할 수 있는 사용자 정의 오류입니다.
///
/// 응답(response) 또는 JSON 문자열 처리 중 발생한 디코딩 오류를 구분하여 처리할 수 있습니다.
enum DecodingError: Error {
    /// 응답 디코딩 중 발생한 오류입니다.
    case responseDecodingError(reason: DecodingReason)
    /// JSON 문자열 디코딩 중 발생한 오류입니다.
    case jsonStringDecodingError(reason: DecodingReason)
    /// 커스텀 메시지를 포함한 오류입니다.
    case custom(message: String)
    
    /// Swift.DecodingError를 기반으로 응답 디코딩 오류를 생성합니다.
    ///
    /// - Parameter error: Swift 표준 디코딩 오류
    /// - Returns: `.responseDecodingError` 타입의 사용자 오류
    static func fromResponse(_ error: Swift.DecodingError) -> Self {
        return .responseDecodingError(reason: DecodingReason(from: error))
    }
    
    /// Swift.DecodingError를 기반으로 페이로드 디코딩 오류를 생성합니다.
    ///
    /// - Parameter error: Swift 표준 디코딩 오류
    /// - Returns: `.jsonStringDecodingError` 타입의 사용자 오류
    static func fromPayload(_ error: Swift.DecodingError) -> Self {
        return .jsonStringDecodingError(reason: DecodingReason(from: error))
    }
}

/// 디코딩 오류의 상세 원인을 정의한 열거형입니다.
///
/// Swift.DecodingError를 분류 가능한 값으로 변환해 제공합니다.
enum DecodingReason {
    /// 타입 불일치
    case typeMismatch
    /// 값 누락
    case valueNotFound
    /// 키 누락
    case keyNotFound
    /// 데이터 손상
    case dataCorrupted
    /// 알 수 없는 오류
    case unknown
    
    /// Swift.DecodingError를 기반으로 해당 열거형 값을 초기화합니다.
    ///
    /// - Parameter error: Swift 표준 디코딩 오류
    init(from error: Swift.DecodingError) {
        switch error {
        case .typeMismatch:
            self = .typeMismatch
        case .valueNotFound:
            self = .valueNotFound
        case .keyNotFound:
            self = .keyNotFound
        case .dataCorrupted:
            self = .dataCorrupted
        @unknown default:
            self = .unknown
        }
    }
}
