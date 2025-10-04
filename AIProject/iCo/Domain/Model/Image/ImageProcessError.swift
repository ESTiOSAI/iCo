//
//  ImageProcessError.swift
//  AIProject
//
//  Created by Kitcat Seo on 8/5/25.
//

import Foundation

/// 이미지 처리 뷰 모델 내 각 함수를 실행하는 과정에서 발생 가능한 에러의 목록들을 담는 Enum
enum ImageProcessError: Error, CustomStringConvertible {
    /// 업비트에서 코인 목록을 불러오지 못했을 때
    case noCoinFetched
    
    /// OCR을 정상 실행했지만 감지된 텍스트가 없을 때
    case noRecognizedText
    
    /// 코인 추출을 정상 실행했지만 감지된 coinID가 없을 때
    case noExtractedCoinID
    
    /// 업비트에서 제공하는 코인이 아닐 때
    case noExistingCoin
    
    /// 기타 Vision 자체에서 발생한 에러
    case unknownVisionError
    
    /// 기타 Alan API에서 발생한 에러
    case unknownAlanError
    
    var description: String {
        switch self {
        case .noRecognizedText:
            return "이미지에서 문자를 찾지 못했어요"
        case .noExtractedCoinID:
            return "이미지에서 코인을 찾지 못했어요"
        case .noExistingCoin:
            return "아이코에 등록되지 않은 코인이에요"
        default:
            return "이미지 처리 중 예상치 못한 문제가 발생했어요"
        }
    }
}
