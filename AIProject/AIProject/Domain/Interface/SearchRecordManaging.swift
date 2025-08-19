//
//  SearchRecordManaging.swift
//  AIProject
//
//  Created by kangho lee on 8/19/25.
//

import Foundation

protocol SearchRecordManaging {
    typealias SearchRecord = SearchRecordEntity
    /// 새로운 검색 기록을 저장
    func save(query: String) throws

    /// 최신 검색 기록을 불러옴
    /// - Parameter limit: 가져올 최대 레코드 수(기본값 10으로 설정)
    func fetchRecent(limit: Int) throws -> [SearchRecord]

    /// 특정 검색 기록을 삭제
    func delete(record: SearchRecord) throws

    /// 모든 검색 기록을 일괄 삭제
    func deleteAll() throws
}
