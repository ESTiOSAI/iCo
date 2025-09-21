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
    
    private static let cornerRadius: CGFloat = 20
    
    var title: String = "주요 뉴스"
    var articles: [CoinArticle]
    
    private var displayedArticles: [CoinArticle] {
        articles.filter { !$0.title.isEmpty || !$0.summary.isEmpty }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title)
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(.aiCoAccent)
            
            ForEach(displayedArticles, id: \.id) { article in
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(article.title.byCharWrapping)
                            .font(.system(size: 15, weight: .bold))
                            .foregroundStyle(.aiCoLabel)
                            .lineLimit(1)
                        
                        Spacer()
                        
//                        RoundedButton(title: "원문보기", imageName: "chevron.right") {
//                             if let url = URL(string: article.newsSourceURL) {
//                                 safariItem = IdentifiableURL(url: url)
//                             }
//                        }
                    }
                    
                    Text(article.summary.byCharWrapping)
                        .font(.system(size: 14))
                        .foregroundStyle(.aiCoLabel)
                        .lineSpacing(6)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.top, 12)
                .padding(.bottom, 16)
                .overlay(alignment: .bottom) {
                    Rectangle()
                        .frame(height: 1)
                        .foregroundStyle(.aiCoBorderGray)
                        .padding(.leading, 0)
                }
            }
        }
        .sheet(item: $safariItem) { item in
            SafariView(url: item.url)
        }
        .padding(.horizontal, 22)
        .padding(.top, 20)
        .padding(.bottom, 20)
        .background(.aiCoBackgroundBlue)
        .clipShape(RoundedRectangle(cornerRadius: Self.cornerRadius))
        .overlay(
            RoundedRectangle(cornerRadius: Self.cornerRadius)
                .strokeBorder(.defaultGradient, lineWidth: 0.5)
        )
    }
}

#Preview {
    ReportNewsSectionView(
        articles: [
            CoinArticle(title: "제목1", summary: "내용1", newsSourceURL: "https://example.com/"),
            CoinArticle(title: "제목2", summary: "내용2", newsSourceURL: "https://example.com/"),
            CoinArticle(title: "제목3", summary: "내용3", newsSourceURL: "https://example.com/")
        ]
    )
    .padding(16)
}
