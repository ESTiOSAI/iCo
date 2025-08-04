//
//  SearchRecordManager.swift
//  AIProject
//
//  Created by 백현진 on 7/31/25.
//

import Foundation
import CoreData

protocol SearchRecordManaging {
    /// 새로운 검색 기록을 저장
    func save(query: String) throws

    /// 최신 검색 기록을 불러옴
    /// - Parameter limit: 가져올 최대 레코드 수(기본값 10으로 설정)
    func fetchRecent(limit: Int) throws -> [SearchRecordEntity]

    /// 특정 검색 기록을 삭제
    func delete(record: SearchRecordEntity) throws

    /// 모든 검색 기록을 일괄 삭제
    func deleteAll() throws
}

final class SearchRecordManager: SearchRecordManaging {

    private let service: CoreDataService

    init(service: CoreDataService = .shared) {
        self.service = service
    }

    func save(query: String) throws {
        let context = service.viewContext

        // 같은 쿼리 있는지 비교 (대소문자 구분 하지 않귀)
        let request: NSFetchRequest<SearchRecordEntity> = SearchRecordEntity.fetchRequest()
        request.predicate = NSPredicate(format: "query = [c] %@", query)
        request.fetchLimit = 1

        // 존재하면 timestamp만, 존재하지 않으면 새로 추가
        let existing = try context.fetch(request)
        if let record = existing.first {
            record.timestamp = Date()
            try context.save()
        } else {
            let record = SearchRecordEntity(context: service.viewContext, query: query)
            service.insert(record)
        }
    }

    func fetchRecent(limit: Int = 10) throws -> [SearchRecordEntity] {
        let sort = NSSortDescriptor(key: "timestamp", ascending: false)
        let all: [SearchRecordEntity] = try service.fetch(nil, sortDescriptors: [sort])
        return Array(all.prefix(limit))
    }

    func delete(record: SearchRecordEntity) throws {
        service.delete(record)
    }

    func deleteAll() throws {
        try service.clear(type: SearchRecordEntity.self)
    }
}
