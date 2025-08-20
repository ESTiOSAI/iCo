//
//  CoinArticleDTO.swift
//  AIProject
//
//  Created by 장지현 on 8/4/25.
//

import Foundation

struct CoinArticleDTO: Codable {
    /// 뉴스 제목
    let title: String
    
    /// 뉴스 한 줄 요약
    let summary: String
    
    /// 뉴스 원문 링크
    let newsSourceURL: String
}
