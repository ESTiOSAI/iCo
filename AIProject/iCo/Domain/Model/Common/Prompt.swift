//
//  Prompt.swift
//  AIProject
//
//  Created by 강대훈 on 8/1/25.
//

/// 정형화된 프롬프트 객체
enum Prompt {
    case recommendCoin(preference: String, bookmark: String)
    case generateOverView(coinKName: String)
    case generateTodayNews(coinKName: String)
    case generateWeeklyTrends(coinKName: String)
    case extractCoinID(text: String)
    case generateTodayInsight
    case generateCommunityInsight(redditPost: String)
    case generateBookmarkBriefing(importance: String, bookmarks: String)

    var content: String {
        switch self {
        case .recommendCoin(let preference, let bookmark):
            """
            - 투자 성향이 \(preference)인 투자자를 위한 가상화폐 추천
            - 오른쪽 코인들은 제외: \(bookmark) 
            - 원화 시장에서 거래 가능한, 실제로 존재하는 코인 10개를 추천
            - 응답은 아래의 JSON 형식으로 작성 (마크다운, JSON 마크다운 금지)
            struct RecommendCoinDTO: Codable {
                let name: String
                let symbol: String
                let comment: String // \(preference)인 투자자에게 추천하는 이유와 최근 동향을 최소 100자 이상의 대화형으로 작성
            }
            """
        case .generateOverView(let coinKName):
            """
            struct CoinOverviewDTO: Codable {
                let symbol: String 
                let websiteURL: String?
                let launchDate: String
                let description: String
            }
            
            "\(coinKName)" 개요를 위 JSON 형식으로 작성 (마크다운 금지, 출처 제외)
            """
        case .generateTodayNews(let coinKName):
            """
            struct CoinTodayNewsDTO: Codable {
                let summaryOfTodaysMarketSentiment: String
                let articles: [CoinArticleDTO] // 3개
            }

            struct CoinArticleDTO: Codable {
                let title: String
                let summary: String
                let newsSourceURL: String
            }

            1. 현재 국내 시간을 기준으로 최근 24시간 뉴스를 분석해 \(coinKName)시장 분위기를 요약
            2. 분석하는데 사용된 뉴스 중 3개를 뉴스 배열에 제목, 요약, 해당 뉴스 출처 링크를 담아 전달

            위 조건에 따라 "\(coinKName)"에 대한 내용을 위 JSON 형식으로 작성 (마크다운 금지, 답변에 출처 금지)
            """
        case .generateWeeklyTrends(let coinKName):
            """
            struct CoinWeeklyDTO: Codable {
                let priceTrend: String
                let volumeChange: String
                let reason: String
            }

            1. 현재 국내 시간을 기준으로 일주일 동안의 정보 사용

            위 조건에 따라 "\(coinKName)"에 대한 내용을 위 JSON 형식으로 작성 (마크다운 금지, 출처 제외)
            """
        case .extractCoinID(let text):
            """
            아래의 문자열에서 가상화폐를 찾아. 빈 배열에 모든 화폐의 심볼을 담고 “,” 로 구분해서 반환해. 응답에 다른 설명은 배제해.
            \(text)
            """
        case.generateTodayInsight:
            """
            struct InsightDTO: Codable {
                /// 주어진 시간 동안의 암호화폐 전체 시장 분위기 (호재 / 악재 / 중립)
                let todaysSentiment: String
                
                /// 내용 요약 (글자수 200자)
                /// 호재의 경우 긍정요인만 or 악재라면 부정 요인만 제공
                /// 중립이라면 긍정요인, 부정요인을 자연스럽게 연결한 문자열을 제공
                let summary: String
            }
            
            1. 현재 국내 시간을 기준으로 최근 2시간 뉴스 기반
            2. 뉴스 전반을 분석해 시장 분위기를 요약 
            
            위 조건에 따라 암호화폐 전체 시장에 대한 내용을 위 JSON 형식으로 작성 (마크다운 금지, 출처 제외)
            """
        case.generateCommunityInsight(let redditPost):
            """
            \(redditPost)
            지금 보낸 건, reddit의 r/CryptoCurrecy community에서, 하루동안 좋아요를 가장 많이 받은 게시물 5개의 제목과 내용이야.
            
            struct InsightDTO: Codable {
                /// 게시물을 기반으로 평가한 커뮤니티 분위기 (호재 / 악재 / 중립)
                let todaysSentiment: String
                /// 커뮤니티 분위기를 그렇게 평가한 이유를 문자열로 요약 (글자수 200자)
                let summary: String
            }
            
            이 게시물들을 InsightDTO를 기반으로 JSON으로 응답해줘(마크다운 금지, 출처 제외).
            """
        case .generateBookmarkBriefing(let importance, let bookmarks):
            """
            struct PortfolioBriefingDTO: Codable {
                let briefing: String
                let strategy: String
            }
            
            1. 분석 대상 코인: \(bookmarks) (한국 이름으로 표시)
            2. 코인별 개별 분석이 아니라, 전체적으로 공통점과 분포(테마, 시가 총액, 최근 7일 가격 흐름, 최근 7일 거래량)를 2줄로 요약
            3. 중요도 반영: \(importance)
            4. 요약문에는 반드시 업계 평균이나 상위/하위 10% 대비 특징을 1개 이상 포함 (예: 거래량이 상위 15% 수준)
            5. 공통점의 강점과 현재 시장 상황을 바탕으로, 단기/장기 중 선택해 이유와 함께 구체적으로 제안
            6. 모든 설명은 숫자, 구체적 시간을 포함
            위 조건에 따라 생성한 내용을 위 JSON 형식으로 작성 (마크다운, 출처, *금지)
            """
        }
    }
}
