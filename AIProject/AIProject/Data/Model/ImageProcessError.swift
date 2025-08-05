//
//  ImageProcessError.swift
//  AIProject
//
//  Created by Kitcat Seo on 8/5/25.
//

import Foundation

/// 이미지 처리 뷰 모델 내 각 함수를 실행하는 과정에서 발생 가능한 에러의 목록들을 담는 Enum
enum ImageProcessError: Error {
    /// OCR을 정상 실행했지만 감지된 텍스트가 없을 때
    case noRecognizedText
    
    /// 코인 추출을 정상 실행했지만 감지된 coinID가 없을 때
    case noExtractedCoinID
    
    /// 기타 Vision 자체에서 발생한 에러
    case unknownVisionError
    
    /// 기타 Alan API에서 발생한 에러
    case unknownAlanError
    
    var message: String {
        switch self {
        case .noRecognizedText:
            return "이미지에서 문자를 찾지 못했어요"
        case .noExtractedCoinID:
            return "이미지에서 코인을 찾지 못했어요"
        default:
            return "이미지 처리 중 예상치 못한 문제가 발생했어요"
        }
    }
}
