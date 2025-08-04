//
//  Prompt.swift
//  AIProject
//
//  Created by 강대훈 on 8/1/25.
//

/// 정형화된 프롬프트 객체
enum Prompt {
    case recommendCoin(preference: String, bookmark: String, coinIDs: String)

    var content: String {
        switch self {
        case .recommendCoin(let preference, let bookmark, let coinIDs):
            """
            코인 5개를 추천해줘.

            너가 추천해줘야 하는 코인 리스트는 다음과 같아.
            -> \(coinIDs)

            현재 나의 코인 투자 선호도는 다음과 같아.
            -> \(preference)

            현재 내가 북마크한 코인은 다음과 같아.
            -> \(bookmark)

            JSON 형식으로 요청할거고, JSON 형식으로만 응답을 줘
            struct RecommendCoinDTO: Codable {
             /// 코인 이름을 영어이름으로 줘
             let name: String
             /// 내가 제공한 coinIDs에 있는 거만 줘
             let symbol: String
             /// 이 코인을 왜 추천했고, 어떤 움직임이 있는지 최근 기사를 인용하여 간략히 작성해줘. 기사 출처는 주지마.
             let comment: String
            }
            """
        }
    }
}
