//
//  CoinOverviewDTO.swift
//  AIProject
//
//  Created by 장지현 on 8/4/25.
//

import Foundation

struct CoinOverviewDTO: Codable {
    /// 심볼
    let symbol: String
    
    /// 웹사이트
    let websiteURL: String?
    
    /// 최초발행
    let launchDate: String
    
    /// 디지털 자산 소개
    let description: String
}
