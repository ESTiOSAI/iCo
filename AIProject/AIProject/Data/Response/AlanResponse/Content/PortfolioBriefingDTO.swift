//
//  PortfolioBriefingDTO.swift
//  AIProject
//
//  Created by 백현진 on 8/6/25.
//

import Foundation

struct PortfolioBriefingDTO: Codable {
    /// 북마크된 코인의 공통점 분석
    let briefing: String
    /// 투자 전략
    let strategy: String
}
