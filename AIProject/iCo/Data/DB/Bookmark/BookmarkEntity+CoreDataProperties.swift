//
//  BookmarkEntity+CoreDataProperties.swift
//  AIProject
//
//  Created by 백현진 on 7/31/25.
//
//

import Foundation
import CoreData


extension BookmarkEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<BookmarkEntity> {
        return NSFetchRequest<BookmarkEntity>(entityName: "BookmarkEntity")
    }

    @NSManaged public var coinID: String
    @NSManaged public var coinKoreanName: String
    @NSManaged public var timestamp: Date

}

extension BookmarkEntity : Identifiable {

}

extension BookmarkEntity {
    /// 코인 심볼을 가져오기 위한 계산 속성
    var coinSymbol: String {
        return coinID.components(separatedBy: "-").last ?? coinID
    }
}

