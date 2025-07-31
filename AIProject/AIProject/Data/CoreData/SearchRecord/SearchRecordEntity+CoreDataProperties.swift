//
//  SearchRecordEntity+CoreDataProperties.swift
//  AIProject
//
//  Created by 백현진 on 7/31/25.
//
//

import Foundation
import CoreData

extension SearchRecordEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SearchRecordEntity> {
        return NSFetchRequest<SearchRecordEntity>(entityName: "SearchRecordEntity")
    }

    @NSManaged public var query: String?
    @NSManaged public var timestamp: Date?

}

extension SearchRecordEntity : Identifiable {

}
