//
//  ReportNewsSectionView.swift
//  AIProject
//
//  Created by 장지현 on 8/11/25.
//

import SwiftUI

/// 보고서 화면에서 주요 뉴스를 나열해 보여주는 전용 뷰입니다.
///
/// `CoinArticle` 배열을 받아 각 뉴스의 제목, 요약, 원문 보기 버튼을 표시합니다.
///
/// - Parameters:
///   - title: 뉴스 섹션의 제목
///   - articles: 표시할 `CoinArticle` 목록
struct ReportNewsSectionView: View {
    @State private var safariItem: IdentifiableURL?
    var title: String = "주요 뉴스"
    var articles: [CoinArticle]
    
    let cornerRadius: CGFloat = 10
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title)
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(.aiCoAccent)
            
            ForEach(Array(articles.enumerated()), id: \.element.id) { index, article in
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(article.title)
                            .font(.system(size: 15, weight: .bold))
                            .foregroundStyle(.aiCoLabel)
                        
                        Spacer()
                        
                        RoundedButton(title: "원문보기") {
                            //                        if let url = URL(string: article.url) {
                            //                            safariItem = IdentifiableURL(url: url)
                            //                        }
                            
                            safariItem = IdentifiableURL(url: URL(string: "https://www.blockmedia.co.kr/archives/956560")!)
                        }
                    }
                    
                    Text(article.summary)
                        .font(.system(size: 15))
                        .foregroundStyle(.aiCoLabel)
                        .lineSpacing(6)
                }
                .padding(.top, 12)
                .padding(.bottom, 16)
                
                if index < articles.count - 1 {
                    Divider()
                        .frame(height: 1)
                        .background(.aiCoBorder)
                }
            }
        }
        .sheet(item: $safariItem) { item in
            SafariView(url: item.url)
        }
        .padding(.horizontal, 22)
        .padding(.top, 20)
        .padding(.bottom, 8)
        .background(.aiCoBackgroundBlue)
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
        .overlay(
            RoundedRectangle(cornerRadius: cornerRadius)
                .stroke(.default, lineWidth: 0.5)
        )
    }
}

#Preview {
    ReportNewsSectionView(articles: [CoinArticle(title: "제목1", summary: "내용1", url: "https://example.com/"), CoinArticle(title: "제목2", summary: "내용2", url: "https://example.com/"), CoinArticle(title: "제목3", summary: "내용3", url: "https://example.com/")])
        .padding(16)
}
