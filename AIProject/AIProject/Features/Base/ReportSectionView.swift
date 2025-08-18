//
//  ReportSectionView.swift
//  AIProject
//
//  Created by 장지현 on 8/11/25.
//

import SwiftUI

/// 보고서 화면에서 아이콘, 제목, 본문 내용을 함께 표시하는 공통 컴포넌트 뷰입니다.
///
/// - Parameters:
///   - imageName: SF Symbol 아이콘 이름
///   - title: 섹션 제목
///   - sentiment: 선택적으로 표시할 감정(`Sentiment`) 정보.
///                값이 제공되면 제목 우측에 감정 설명과 해당 색상을 함께 표시합니다.
///   - content: 표시할 본문 내용(`AttributedString`)
///              텍스트 스타일, 색상, 링크 등 리치 텍스트 속성을 적용하기 위해 사용합니다.
struct ReportSectionView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @Binding var status: ResponseStatus
    
    private static let cornerRadius: CGFloat = 10
    
    var imageName: String
    var title: String
    var sentiment: Sentiment?
    var content: AttributedString
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: imageName)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.aiCoAccent)
                
                Text(title)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.aiCoLabel)
                
                Spacer()
                
                if let sentiment {
                    Text(sentiment.rawValue)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(sentiment.color(for: themeManager.selectedTheme))
                }
            }
            
            StatusSwitch(status: status, backgroundColor: .aiCoBackground) {
                Text(content)
                    .font(.system(size: 14))
                    .foregroundStyle(.aiCoLabel)
                    .lineSpacing(6)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(.horizontal, 22)
        .padding(.vertical, 20)
        .background(.aiCoBackground)
        .clipShape(RoundedRectangle(cornerRadius: Self.cornerRadius))
        .overlay(
            RoundedRectangle(cornerRadius: Self.cornerRadius)
                .stroke(.default, lineWidth: 0.5)
        )
    }
}

#Preview {
    ReportSectionView(
        status: .constant(.success),
        imageName: "text.page.badge.magnifyingglass",
        title: "한눈에 보는 이더리움",
        content: AttributedString("""
        - 심볼: ETH
        - 웹사이트: https://ethereum.org
        - 최초발행: 2015-07-30
        - 소개: 이더리움(Ethereum)은 블록체인 기술을 기반으로 한 탈중앙화 컴퓨팅 플랫폼으로, 스마트 계약 기능을 통해 분산 애플리케이션(DApps)을 구축할 수 있습니다. 2015년 7월 30일 비탈릭 부테린에 의해 출시되었으며, 이더리움의 네이티브 암호화폐는 이더(ETH)로, 플랫폼 내에서 거래 및 스마트 계약 실행에 사용됩니다.
        """)
    )
    .padding(16)
    
    ReportSectionView(
        status: .constant(.success),
        imageName: "bitcoinsign.bank.building",
        title: "전반적인 시장의 분위기",
        sentiment: Sentiment.positive,
        content: AttributedString("""
        비트코인은 약 $114,900~115,000 수준에서 반등하며 강세 흐름을 이어가고 있고, 이더리움 역시 최근 상승세를 보이며 투자자 심리를 지지하고 있습니다.
        연준의 금리 인하 기대가 커지면서 달러 약세 및 위험자산 선호로 전체적으로 긍정적인 투자 분위기가 조성되고 있습니다.
        다만, 이더리움에 대한 기관 자금 유입이 활발한 상황에서 스테이킹 관련 규제와 시장 변동성은 여전히 주의 요인입니다.
        """)
    )
    .padding(16)
}
