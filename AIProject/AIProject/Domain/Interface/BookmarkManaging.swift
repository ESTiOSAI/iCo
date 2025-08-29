//
//  BookmarkManaging.swift
//  AIProject
//
//  Created by kangho lee on 8/19/25.
//

import Foundation

protocol BookmarkManaging {
    typealias Bookmark = BookmarkEntity
    /// 북마크 추가 (저장)
    func add(coinID: String, coinKoreanName: String) throws

    /// 북마크 삭제 (해제)
    func remove(coinID: String) throws

    /// 최근 북마크 목록 조회
    func fetchRecent(limit: Int) throws -> [Bookmark]

    /// 전체 북마크 목록 가져오기
    func fetchAll() throws -> [Bookmark]

    /// 모든 북마크 일괄 삭제
    func deleteAll() throws

    /// 현재 상태를 반전시키는 토글 메서드
    /// - Returns: 토글 후 북마크 관리 상태 (true: 설정됨, false: 해제됨)
    @discardableResult
    func toggle(coinID: String, coinKoreanName: String) throws -> Bool

    /// 특정 코인이 현재 북마크 상태인지 확인
    func isBookmarked(_ coinID: String) throws -> Bool
}
