//
//  CoinImageEntity+CoreDataProperties.swift
//  AIProject
//
//  Created by 백현진 on 8/18/25.
//
//

import Foundation
import CoreData


extension CoinImageEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CoinImageEntity> {
        return NSFetchRequest<CoinImageEntity>(entityName: "CoinImageEntity")
    }

    @NSManaged public var symbol: String?
    @NSManaged public var imageURL: String?

}

extension CoinImageEntity : Identifiable {

}
