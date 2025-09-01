//
//  RiskTolerance.swift
//  AIProject
//
//  Created by 장지현 on 8/10/25.
//

import Foundation

enum RiskTolerance: String, CaseIterable {
    case conservative = "안정형"
    case moderatelyConservative = "안정추구형"
    case moderate = "위험중립형"
    case moderatelyAggressive = "적극투자형"
    case aggressive = "공격투자형"
}
