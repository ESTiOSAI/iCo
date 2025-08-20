//
//  FearGreedResponseDTO.swift
//  AIProject
//
//  Created by 장지현 on 8/6/25.
//

import Foundation

struct FearGreedResponseDTO: Codable {
    let data: [FearGreedIndexDTO]
}

struct FearGreedIndexDTO: Codable {
    /// 공포 탐욕 지수
    let value: String
    /// 공포 탐욕 상태
    let valueClassification: String
    /// 기준 시간 (Unix Epoch)
    let timestamp: String
    /// 기준 시간으로 부터 경과한 시간 (Unix Epoch)
    let timeUntilUpdate: String
    
    enum CodingKeys: String, CodingKey {
        case value = "value"
        case valueClassification = "value_classification"
        case timestamp = "timestamp"
        case timeUntilUpdate = "time_until_update"
    }
}
