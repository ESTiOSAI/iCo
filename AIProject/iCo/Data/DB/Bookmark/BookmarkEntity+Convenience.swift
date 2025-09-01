//
//  BookmarkEntity+Convenience.swift
//  AIProject
//
//  Created by 백현진 on 7/31/25.
//

import CoreData

extension BookmarkEntity {
    /// Convenience initializer
    /// - Parameters:
    /// - context: NSManagedObjectContext
    /// - coinID: 코인(market-name)이름 문자열
    /// - timestamp: 북마크 등록 시간 (기본값: 현재 시간)
    convenience init(context: NSManagedObjectContext,
                     coinID: String,
                     coinKoreanName: String,
                     timestamp: Date = Date()) {
        let entity = NSEntityDescription.entity(forEntityName: "BookmarkEntity",
                                                in: context)!
        self.init(entity: entity, insertInto: context)
        self.coinID = coinID
        self.coinKoreanName = coinKoreanName
        self.timestamp = timestamp
    }
}
