//
//  Prompt.swift
//  AIProject
//
//  Created by 강대훈 on 8/1/25.
//

import Foundation

/// 정형화된 프롬프트 객체
enum Prompt {
    case recommendCoin(preference: String, bookmark: String)
    case generateOverView(coinKName: String)
    case generateTodayNews(coinKName: String, today: String = Date().dateAndTime)
    case generateWeeklyTrends(coinKName: String, today: String = Date().dateAndTime)
    case extractCoinID(text: String)
    case generateTodayInsight(today: String = Date().dateAndTime)
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
                let comment: String // \(preference)인 투자자에게 추천하는 이유와 최근 동향을 100자 정도의 대화형으로 작성
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
            
            "\(coinKName)" 개요를 위 JSON 형식으로 답변 (답변은 한글, 마크다운 금지, 출처 제외)
            """
        case .generateTodayNews(let coinKName, let today):
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
            
            \(today) 기준 최근 24시간 한국 뉴스를 분석해 \(coinKName) 시장 분위기를 요약
            분석하는데 사용된 뉴스 중 3개를 뉴스 배열에 제목, 요약, 해당 뉴스 출처 링크를 담아 전달
            위 JSON 형식으로 작성 (답변은 한글, 마크다운 금지, 출처 제외)
            """
        case .generateWeeklyTrends(let coinKName, let today):
            """
            struct CoinWeeklyDTO: Codable {
                let coinWeeklyPriceSummary: String
                let coinWeeklyVolumeSummary: String
                let reason: String
            }
            
            \(today) 기준 일주일 동안의 가격 추이, 거래량 변화 요약
            "\(coinKName)"에 대해 위 JSON 형식으로 작성 (답변은 한글, 마크다운 금지, 출처 제외)
            """
        case .extractCoinID(let text):
            """
            아래의 문자열에서 가상화폐를 찾아. 빈 배열에 모든 화폐의 심볼을 담고 “,” 로 구분해서 반환해. 응답에 다른 설명은 배제해.
            \(text)
            """
        case.generateTodayInsight(let today):
            """
            struct InsightDTO: Codable {
                let todaysSentiment: String
                let summary: String
            }
            
            \(today) 기준 최근 2시간동안 한국 암호화폐 뉴스 분석 후 분위기(호재, 악재, 중립)와 그렇게 판단한 이유 200자로 요약
            이유는 호재라면 긍정 요인, 악재라면 부정 요인만 요약, 중립이라면 긍정, 부정 요인을 자연스럽게 연결해 요약 
            위 JSON 형식으로 작성 (답변은 한글, 마크다운 금지, 출처 제외)
            """
        case.generateCommunityInsight(let redditPost):
            """
            \(redditPost)
            위 내용은 reddit의 r/CryptoCurrecy community의 top 5 게시물의 제목과 내용
            
            struct InsightDTO: Codable {
                let todaysSentiment: String
                let summary: String
            }
            
            커뮤니티 분위기(호재, 악재, 중립)와 그렇게 평가한 이유를 한글로 200자로 요약해 위 JSON으로 제공 (답변은 한글, 마크다운 금지, 출처 제외)
            """
        case .generateBookmarkBriefing(let importance, let bookmarks):
            """
            struct PortfolioBriefingDTO: Codable {
                let briefing: String
                let strategy: String
            }
            
            1. 분석 대상 코인: \(bookmarks)
            2. 코인별 개별 분석이 아니라, 전체적으로 공통점과 분포(테마, 시가 총액, 최근 7일 가격 흐름과 거래량)를 2줄로 요약
            3. 중요도 반영: \(importance)
            4. 요약문에는 반드시 업계 평균이나 상위/하위 10% 대비 특징을 1개 이상 포함 (예: 거래량이 상위 15% 수준)
            5. 공통점의 강점과 현재 시장 상황을 바탕으로, 단기/장기 중 선택해 이유와 함께 구체적으로 제안
            6. 모든 설명은 숫자, 구체적 시간을 포함
            7. 마크다운과 출처 금지
            위 조건에 따라 생성한 내용을 위 JSON 형식으로 작성
            """
        }
    }
}
