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

    /// 특정 검색 기록(객체)을 삭제
    func delete(record: SearchRecord) throws

    /// 특정 검색 기록(쿼리로) 삭제
    func delete(query: String) throws

    /// 모든 검색 기록을 일괄 삭제
    func deleteAll() throws
}
