//
//  BookmarkManager.swift
//  AIProject
//
//  Created by 백현진 on 7/31/25.
//

import Foundation
import CoreData

final class BookmarkManager: BookmarkManaging {
    static let shared = BookmarkManager()

    private let service: CoreDataService

    private init(service: CoreDataService = .shared) {
        self.service = service
    }

    func add(coinID: String, coinKoreanName: String) throws {
        let context = service.viewContext
        // 중복 방지
        let request: NSFetchRequest<BookmarkEntity> = BookmarkEntity.fetchRequest()
        request.predicate = NSPredicate(format: "coinID = %@", coinID)
        request.fetchLimit = 1

        let existing = try context.fetch(request)
        if existing.first == nil {
            let bookmark = BookmarkEntity(context: context)
            bookmark.coinID = coinID
            bookmark.coinKoreanName = coinKoreanName
            bookmark.timestamp = Date()
            service.insert(bookmark)
        }
    }

    func remove(coinID: String) throws {
        let context = service.viewContext
        let request: NSFetchRequest<BookmarkEntity> = BookmarkEntity.fetchRequest()
        request.predicate = NSPredicate(format: "coinID = %@", coinID)
        request.fetchLimit = 1

        if let bookmark = try context.fetch(request).first {
            service.delete(bookmark)
        }
    }

    func fetchRecent(limit: Int = 10) throws -> [BookmarkEntity] {
        let sort = NSSortDescriptor(key: "timestamp", ascending: false)
        let all: [BookmarkEntity] = try service.fetch(nil, sortDescriptors: [sort])
        return Array(all.prefix(limit))
    }

    func fetchAll() throws -> [BookmarkEntity] {
        // 누적된 모든 북마크를 시간순(desc)으로 리턴
        let sort = NSSortDescriptor(key: "timestamp", ascending: false)
        return try service.fetch(nil, sortDescriptors: [sort])
    }

    func deleteAll() throws {
        try service.clear(type: BookmarkEntity.self)
    }

    @discardableResult
    /// 주어진 coinID가 이미 북마크되어 있는지 확인 후,
    /// 저장 ↔ 삭제를 수행하고, 최종 상태를 반환.
    func toggle(coinID: String, coinKoreanName: String) throws -> Bool {
        if try isBookmarked(coinID) {
            try remove(coinID: coinID)
            return false
        } else {
            try add(coinID: coinID, coinKoreanName: coinKoreanName)
            return true
        }
    }

    @available(*, deprecated, message: "Use toggle(coinID:coinKoreanName:) instead")
    func toggle(coinID: String) throws -> Bool {
        throw NSError(domain: "BookmarkManager", code: 999, userInfo: [
            NSLocalizedDescriptionKey: "이 메서드는 더 이상 사용되지 않습니다. 한글 이름을 함께 전달해야 합니다."
        ])
    }

    // 이미 북마크에 존재하는지 체크
    func isBookmarked(_ coinID: String) throws -> Bool {
        let request: NSFetchRequest<BookmarkEntity> = BookmarkEntity.fetchRequest()
        request.predicate = NSPredicate(format: "coinID = %@", coinID)
        request.fetchLimit = 1
        let existing = try service.viewContext.fetch(request)
        return existing.first != nil
    }
}
