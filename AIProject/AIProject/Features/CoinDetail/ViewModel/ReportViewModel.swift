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
    
    init(coin: Coin) {
        self.coin = coin
        self.koreanName = coin.koreanName
        fetchOverView()
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
                guard let jsonData = extractJSON(from: answer.content).data(using: .utf8) else {
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
        struct CoinOverview { // 주석은 주어진 키워드가 '이더리움'인 경우 예상 응답
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
            decodeType: CoinOverview.self,
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

func extractJSON(from raw: String) -> String {
    guard let startRange = raw.range(of: "```json") else { return raw }
    guard let endRange = raw.range(of: "```", options: .backwards) else { return raw }
    
    let jsonStartIndex = raw.index(after: startRange.upperBound)
    let jsonString = String(raw[jsonStartIndex..<endRange.lowerBound])
    
    return jsonString.trimmingCharacters(in: .whitespacesAndNewlines)
}

struct CoinOverview: Codable {
    /// 심볼
    let symbol: String
    
    /// 웹사이트
    let websiteURL: String?
    
    /// 최초발행
    let startDate: String
    
    /// 디지털 자산 소개
    let description: String
}
