//
//  SearchRecordManager.swift
//  AIProject
//
//  Created by 백현진 on 7/31/25.
//

import Foundation
import CoreData

final class SearchRecordManager: SearchRecordManaging {

    private let service: CoreDataService
    /// 검색 기록 최대 저장 수
    private let maxCount = 10

    init(service: CoreDataService = .shared) {
        self.service = service
    }

    func save(query: String) throws {
        let context = service.viewContext

        // 같은 쿼리 있는지 비교 (대소문자 구분 하지 않기)
        let request: NSFetchRequest<SearchRecordEntity> = SearchRecordEntity.fetchRequest()
        request.predicate = NSPredicate(format: "query = [c] %@", query)
        request.fetchLimit = 1

        let existing = try context.fetch(request)
        if let record = existing.first {
            // 이미 있으면 timeStamp만 수정
            record.timestamp = Date()
            try context.save()
        } else {
            // 중복 없으면 저장
            let record = SearchRecordEntity(context: service.viewContext, query: query)
            service.insert(record)
        }

        let fetchAll: NSFetchRequest<SearchRecordEntity> = SearchRecordEntity.fetchRequest()
        fetchAll.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false)]
        let all = try context.fetch(fetchAll)

        // 초과된 기록(maxCount기준) 삭제
        if all.count > maxCount {
            let excess = all.suffix(from: maxCount)
            for oldRecord in excess {
                service.delete(oldRecord)
            }
        }
    }

    func delete(record: SearchRecordEntity) throws {
        service.delete(record)
    }

    func delete(query: String) throws {
        let request: NSFetchRequest<SearchRecordEntity> = SearchRecordEntity.fetchRequest()
        request.predicate = NSPredicate(format: "query = [c] %@", query)
        request.fetchLimit = 1

        if let record = try service.viewContext.fetch(request).first {
            try delete(record: record)
        }
    }

    func deleteAll() throws {
        try service.clear(type: SearchRecordEntity.self)
    }
}
