//
//  ReportViewModel.swift
//  AIProject
//
//  Created by 장지현 on 8/1/25.
//

import Foundation

final class ReportViewModel: ObservableObject {
    let coin: Coin
    let koreanName: String
    @Published var coinOverView: String = "AI가 정보를 준비하고 있어요"
    @Published var coinTodayTrends: String = "AI가 정보를 준비하고 있어요"
    @Published var coinWeeklyTrends: String = "AI가 정보를 준비하고 있어요"
    @Published var coinTodayTopNews: [CoinArticle] = [CoinArticle(title: "", summary: "AI가 정보를 준비하고 있어요", url: "https://example.com/news1")]
    
    init(coin: Coin) {
        self.coin = coin
        self.koreanName = coin.koreanName
        fetchOverView()
        fetchTodayTopNews()
        fetchWeeklyTrends()
    }
    
    private func fetch<T: Decodable>(
        content: String,
        decodeType: T.Type,
        onSuccess: @escaping (T) -> Void,
        onFailure: @escaping () -> Void
    ) {
        Task {
            do {
                let answer = try await AlanAPIService().fetchAnswer(content: content)
                guard let jsonData = answer.content.extractedJSON.data(using: .utf8) else {
                    await MainActor.run { onFailure() }
                    return
                }
                let data = try JSONDecoder().decode(T.self, from: jsonData)
                await MainActor.run { onSuccess(data) }
            } catch {
                print("오류 발생: \(error.localizedDescription)")
                await MainActor.run { onFailure() }
            }
        }
    }
    
    private func fetchOverView() {
        let content = """
        struct CoinOverviewDTO: Codable { // 주석은 주어진 키워드가 '이더리움'인 경우 예상 응답
            /// 심볼: ETH
            let symbol: String 
            
            /// 웹사이트: https://ethereum.org/ko/
            let websiteURL: String?
            
            /// 최초발행: 2015.07.
            let startDate: String
            
            /// 디지털 자산 소개, 문장을 자연스럽게 연결하기 :
            /// 이더리움은 비탈릭 부테린이 개발한 블록체인 기반의 분산 컴퓨팅 플랫폼이자 운영 체제입니다. 스마트 계약 기능을 제공하여 다양한 탈중앙화 애플리케이션(DApps)을 개발할 수 있도록 지원합니다. 이더리움의 네이티브 암호화폐인 이더(ETH)는 네트워크에서의 거래 수수료 및 계산 서비스를 위한 연료로 사용됩니다. 이더리움은 블록체인 기술의 활용 범위를 확장하여 디지털 자산의 새로운 가능성을 열었습니다.
            let description: String
        }
        
        1. 답변할 항목은 위에 제공한 Swift 구조체의 주석에 따라 내용을 구성
        2. JSON 형식과 변수 또한 제공한 구조체와 통일
        3. 마크다운 사용 금지
        위 세가지 규칙을 적용해서 코인 "\(coin.koreanName)"에 대한 개요를 JSON 형식으로 답변해줘.
        """
        
        fetch(
            content: content,
            decodeType: CoinOverviewDTO.self,
            onSuccess: { data in
                self.coinOverView = """
                    ‣ 심볼: \(data.symbol)
                    ‣ 웹사이트: \(data.websiteURL ?? "없음")
                    
                    ‣ 최초발행: \(data.startDate)
                    
                    ‣ 소개: \(data.description)
                    """
            },
            onFailure: {
                self.coinOverView = "데이터를 불러오는 데 실패했어요"
            }
        )
    }
    
    private func fetchTodayTopNews() {
        let content = """
            struct CoinTodayNewsDTO: Codable { // 주석은 주어진 키워드가 '비트코인'인 경우 예상 응답
                /// 오늘 시장 분위기
                /// 비트코인은 최근 아마존을 제치고 세계 5위 자산으로 올라서는 성과를 달성했으나, 최근 5일 연속 가격이 하락하며 3주 만에 최저치를 기록했습니다. 8월은 비수기로 예상되며, 가격이 11만 2000달러까지 하락할 가능성이 제기되고 있습니다. JP모건 CEO는 비트코인에 대한 회의적인 입장을 밝히면서도 고객의 선택을 존중하겠다는 입장을 표명했습니다. 가상화폐 시장 전반이 하락세를 보이고 있으며, 주요 코인들이 큰 폭으로 하락하고 있습니다. 시장 분위기는 전반적으로 부정적이며, 가격 하락과 비수기 전망으로 인해 투자자들의 불안감이 커지고 있습니다.
                let today: String
                
                /// 뉴스 배열, 3개
                let articles: [CoinArticleDTO]
            }
        
            struct CoinArticleDTO: Codable {
                /// 뉴스 헤드라인
                let title: String
                
                /// 뉴스 한 줄 요약
                let summary: String
                
                /// 뉴스 원문 링크
                let url: String
            }
        
            1. 답변할 항목은 위에 제공한 Swift 구조체의 주석에 따라 내용을 구성
            2. JSON 형식과 변수 또한 구조체와 통일
            3. 오늘 시장 분위기(today)의 경우에는 현재 국내 시간을 기준으로 24시간 동안의 뉴스를 근거로 간단하게 요약
            4. 뉴스 배열의 경우에는 현재 국내 시간을 기준으로 24시간 동안의 뉴스 top 3 헤드라인과 한줄 요약을 제공
            5. 마크다운 문법 사용 금지
        
            위 다섯가지 규칙을 적용해서 "\(coin.koreanName)"에 대한 오늘 시장 분위기 요약본과 뉴스 배열을 제공해줘.
        """
        
        fetch(
            content: content,
            decodeType: CoinTodayNewsDTO.self,
            onSuccess: { data in
                self.coinTodayTrends = data.today
                self.coinTodayTopNews = data.articles.map { CoinArticle(from: $0) }
            },
            onFailure: {
                self.coinTodayTrends = "데이터를 불러오는 데 실패했어요"
                self.coinTodayTopNews = [CoinArticle(title: "데이터를 불러오는데 실패했어요", summary: "", url: "")]
            }
        )
    }
    
    private func fetchWeeklyTrends() {
        let content = """
            struct CoinWeeklyDTO: Codable {
                /// 최근 일주일 가격 추이
                let priceTrend: String
                
                /// 최근 일주일 거래량 변화
                let volumeChange: String
                
                /// 지난 일주일간 가격 추이와 거래량 변화의 주요 원인
                let reason: String
            }
            
            1. 답변할 항목은 위에 제공한 Swift 구조체의 주석에 따라 내용을 구성
            2. JSON 형식과 변수 또한 구조체와 통일
            3. 현재 국내 시간을 기준으로 일주일 동안의 정보 사용
            4. 출처 제외
            5. 마크다운 문법 사용 금지
        
            위 다섯가지 규칙을 적용해서 "\(coin.koreanName)"의 최근 일주일 가격 추이 및 거래량 변화 그리고 그 원인을 알려줘.
        """
        
        fetch(
            content: content,
            decodeType: CoinWeeklyDTO.self,
            onSuccess: { data in
                self.coinWeeklyTrends = """
                    ‣ 가격 추이: \(data.priceTrend)
                    
                    ‣ 거래량 변화: \(data.volumeChange)
                    
                    ‣ 원인: \(data.reason)
                    """
            },
            onFailure: {
                self.coinWeeklyTrends = "데이터를 불러오는 데 실패했어요"
            }
        )
    }
}
