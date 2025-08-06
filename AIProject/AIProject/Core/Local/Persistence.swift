//
//  Persistence.swift
//  AIProject
//
//  Created by kangho lee on 7/29/25.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    @MainActor
    static let preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        for _ in 0..<10 {
            let newItem = Item(context: viewContext)
            newItem.timestamp = Date()
        }
        do {
            try viewContext.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "AIProject")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        //        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
        //            if let error = error as NSError? {
        //                // Replace this implementation with code to handle the error appropriately.
        //                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        //
        //                /*
        //                 Typical reasons for an error here include:
        //                 * The parent directory does not exist, cannot be created, or disallows writing.
        //                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
        //                 * The device is out of space.
        //                 * The store could not be migrated to the current model version.
        //                 Check the error message to determine what the actual problem was.
        //                 */
        //                fatalError("Unresolved error \(error), \(error.userInfo)")
        //            }
        //        })
        //        container.viewContext.automaticallyMergesChangesFromParent = true
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Unresolved error \(error)")
            }
        }

        //MARK: - 북마크 테스트
        let context = container.viewContext
        // 1) 기존에 엔티티가 하나도 없을 때만 시딩
        let fetchReq: NSFetchRequest<BookmarkEntity> = BookmarkEntity.fetchRequest()
        let count = (try? context.count(for: fetchReq)) ?? 0
        guard count == 0 else { return }

        // 2) 초기 북마크로 넣고 싶은 coinID 목록
        let initialCoinIDs = ["KRW-STRIKE", "KRW-SOL", "KRW-AHT"]

        // 3) 각각 BookmarkEntity 생성
        initialCoinIDs.forEach { id in
            let bookmark = BookmarkEntity(context: context)
            bookmark.coinID = id
            bookmark.timestamp = Date()
        }

        // 4) 저장
        do {
            try context.save()
            print("✅ Seeded \(initialCoinIDs.count) bookmarks")
        } catch {
            print("❌ Seed failed:", error)
        }
    }

}

