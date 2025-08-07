//
//  CoinInterval.swift
//  AIProject
//
//  Created by 강민지 on 8/1/25.
//

import Foundation

/// 코인 차트에서 기간을 나타내는 구조체 모델
/// API 요청 시 필요한 시작 날짜 계산 및 구간 식별에 사용
struct CoinInterval: Identifiable, Hashable {
    /// 기간 ID (예: "1D", "1W" 등)
    let id: String
    /// 현재 시점을 기준으로 몇 분 전부터 데이터를 조회할지 나타내는 분 단위 값
    let minutes: Int
    /// 시작일 계산: 현재 시점에서 `minutes` 만큼 이전 시각
    var startDate: Date {
        Calendar.current.date(byAdding: .minute, value: -minutes, to: Date())!
    }
    /// 종료일: 항상 현재 시각 기준
    var endDate: Date {
        Date()
    }

    /// 사용 가능한 전체 기간 옵션 목록
    static let all: [CoinInterval] = [
        CoinInterval(id: "1D", minutes: 1440), // 1일 == 1440분
        CoinInterval(id: "1W", minutes: 1440 * 7),
        CoinInterval(id: "3M", minutes: 1440 * 30 * 3),
        CoinInterval(id: "6M", minutes: 1440 * 30 * 6),
        CoinInterval(id: "1Y", minutes: 1440 * 365)
    ]
}
