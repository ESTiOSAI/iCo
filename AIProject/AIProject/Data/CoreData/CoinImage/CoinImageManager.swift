//
//  CoinImageManager.swift
//  AIProject
//
//  Created by 백현진 on 8/18/25.
//

import Foundation
import CoreData

final class CoinImageManager {
    static let shared = CoinImageManager()
    private let service = CoreDataService.shared

    /// 매핑된 [String: URL]을 coinImageEntity에 저장
    func addDict(_ dict: [String: URL]) throws {
        guard !dict.isEmpty else { return }

        for (symbol, url) in dict {
            let upper = symbol.uppercased()

            let request: NSFetchRequest<CoinImageEntity> = CoinImageEntity.fetchRequest()
            request.predicate = NSPredicate(format: "symbol == %@", upper)
            request.fetchLimit = 1

            if let existing = try service.viewContext.fetch(request).first {
                // 이미 있으면 imageURL 업데이트
                existing.imageURL = url.absoluteString
            } else {
                let entity = CoinImageEntity(context: service.viewContext)
                entity.symbol = upper
                entity.imageURL = url.absoluteString
            }
        }

        try service.viewContext.save()
    }

    /// 심볼에 해당하는 URL 조회
    func url(for symbol: String) -> URL? {
        let request: NSFetchRequest<CoinImageEntity> = CoinImageEntity.fetchRequest()
        request.predicate = NSPredicate(format: "symbol == %@", symbol.uppercased())
        request.fetchLimit = 1

        guard let entity = try? service.viewContext.fetch(request).first,
              let urlStr = entity.imageURL else {
            return nil
        }
        return URL(string: urlStr)
    }
}

