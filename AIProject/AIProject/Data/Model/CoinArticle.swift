//
//  CoinArticleDTO.swift
//  AIProject
//
//  Created by 장지현 on 8/4/25.
//

import Foundation

struct CoinArticle: Identifiable {
    /// 뉴스 제목
    let title: String
    
    /// 뉴스 한 줄 요약
    let summary: String
    
    /// 뉴스 원문 링크
    let url: String
    
    var id: Int {
        "\(title)\(url)".hashValue
    }
}

extension CoinArticle {
    init(from dto: CoinArticleDTO) {
        self.title = dto.title
        self.summary = dto.summary
        self.url = dto.url
    }
}
