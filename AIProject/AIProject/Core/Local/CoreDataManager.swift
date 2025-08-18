//
//  CoreDataManager.swift
//  AIProject
//
//  Created by 백현진 on 7/31/25.
//

import CoreData
import Foundation

final class CoreDataService {
    static let shared = CoreDataService(container: PersistenceController.shared.container)
    private let container: NSPersistentContainer
    var viewContext: NSManagedObjectContext {
        container.viewContext
    }

    private init(container: NSPersistentContainer) {
        self.container = container
    }

    func fetch<T: NSManagedObject>(_ predicate: NSPredicate? = nil,
                                   sortDescriptors: [NSSortDescriptor] = []) throws -> [T] {
        let request = NSFetchRequest<T>(entityName: String(describing: T.self))
        request.predicate = predicate
        request.sortDescriptors = sortDescriptors
        return try viewContext.fetch(request)
    }

    func insert(_ object: NSManagedObject) {
        viewContext.insert(object)
        saveContext()
    }

    func delete(_ object: NSManagedObject) {
        viewContext.delete(object)
        saveContext()
    }

    func clear<T: NSManagedObject>(type: T.Type) throws {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: String(describing: T.self))
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

        batchDeleteRequest.resultType = .resultTypeObjectIDs

        let result = try container.persistentStoreCoordinator.execute(batchDeleteRequest, with: viewContext) as? NSBatchDeleteResult

        if let objectIDs = result?.result as? [NSManagedObjectID] {
            let changes: [AnyHashable: Any] = [
                NSDeletedObjectsKey: objectIDs
            ]
            // context에 merge → @FetchRequest 감지됨
            NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [viewContext])
        }
    }

    private func saveContext() {
        guard viewContext.hasChanges else { return }
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved Core Data error \(nsError), \(nsError.userInfo)")
        }
    }
}
