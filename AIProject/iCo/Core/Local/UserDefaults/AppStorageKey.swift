//
//  AppStorageKey.swift
//  AIProject
//
//  Created by 장지현 on 8/11/25.
//

import Foundation

/// 앱 전역에서 사용하는 `AppStorage` 키 값을 정의한 열거형입니다.
///
/// 문자열 하드코딩을 방지하고, 키 관리의 일관성을 유지하기 위해 사용됩니다.

enum AppStorageKey {
    /// 사용자의 투자 성향(`InvestmentType`) 저장 키
    static let investmentType = "investmentType"
    /// 선택된 앱 테마 저장 키
    static let theme = "selectedTheme"
    /// 코인 이미지 매핑 정보 저장 키
    static let imageMap = "imageMap"
    /// AI 추천 코인 URL 캐시 키
    static let cacheCoinRecomURL = "cacheCoinRecomURL"
    /// AI 추천 코인 URL 캐시 시각 저장 키
    static let cacheCoinRecomTimestamp = "cacheCoinRecomTimestamp"
    /// 오늘의 브리핑 캐시 시각 저장 키
    static let cacheBriefTodayTimestamp = "cacheBriefTodayTimestamp"
    /// 커뮤니티 브리핑 캐시 시각 저장 키
    static let cacheBriefCommunityTimestamp = "cacheBriefCommunityTimestamp"
}
