//
//  Prompt.swift
//  AIProject
//
//  Created by 강대훈 on 8/1/25.
//

/// 정형화된 프롬프트 객체
enum Prompt {
    case recommendCoin(preference: String, bookmark: String)

    var content: String {
        switch self {
        case .recommendCoin(let preference, let bookmark):
"""
                     코인 5개를 추천해줘.
            
                     현재 나의 코인 투자 선호도는 다음과 같아.
                     -> \(preference)
            
                     현재 내가 북마크한 코인은 다음과 같아.
                     -> \(bookmark)
            
                     JSON 형식으로 요청할거고, JSON 형식으로만 응답을 줘
                     struct RecommendCoinDTO: Codable {
                         let name: String
                         let symbol: String
                         let comment: String
                     }
"""
        }
    }
}
