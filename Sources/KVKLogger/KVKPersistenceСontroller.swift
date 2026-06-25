//
//  KVKPersistenceСontroller.swift
//
//
//  Created by Sergei Kviatkovskii on 1/31/23.
//

import CoreData

final class KVKPersistenceСontroller: Sendable {

    let container: NSPersistentContainer
    let backgroundContext: NSManagedObjectContext
    let isReady: Bool
    var viewContext: NSManagedObjectContext {
        container.viewContext
    }
    /// Returns the file size of the SQLite store without loading it into memory.
    var dbSize: String? {
        guard let cacheDBURL,
              let attrs = try? FileManager.default.attributesOfItem(atPath: cacheDBURL.path),
              let bytes = attrs[.size] as? Int64 else { return nil }
        return Self.byteFormatter.string(fromByteCount: bytes)
    }
    private let cacheDBURL: URL?
    private static let byteFormatter: ByteCountFormatter = {
        let f = ByteCountFormatter()
        f.allowedUnits = [.useAll]
        f.countStyle = .file
        return f
    }()

    init(inMemory: Bool = false) {
        let url = dataBaseURL
        cacheDBURL = inMemory ? nil : url
        let dbName = url.lastPathComponent
        container = NSPersistentContainer(name: dbName, managedObjectModel: dbModel)

        if inMemory {
            if let firstDescription = container.persistentStoreDescriptions.first {
                if #available(iOS 16.0, macOS 13.0, *) {
                    firstDescription.url = URL(filePath: "/dev/null")
                } else {
                    firstDescription.url = URL(fileURLWithPath: "/dev/null")
                }
            }
        } else {
            let store = NSPersistentStoreDescription(url: url)
            store.shouldMigrateStoreAutomatically = true
            store.shouldInferMappingModelAutomatically = true
            container.persistentStoreDescriptions = [store]
        }

        var loaded = true
        container.loadPersistentStores { (_, error) in
            if let error = error as? NSError {
                loaded = false
                debugPrint("KVKLogger: Unresolved error \(error), \(error.userInfo)")
            }
        }
        isReady = loaded
        backgroundContext = container.newBackgroundContext()
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump

        if isReady {
            checkOldRecordsAndDeleteIfNeeded()
        }
    }

    func save(log: ItemLogProxy) {
        guard isReady else { return }
        backgroundContext.performAndWait {
            do {
                let itemLog = ItemLog(context: self.backgroundContext)
                itemLog.createdAt_ = log.createdAt
                itemLog.data_ = log.data
                itemLog.details_ = log.details
                itemLog.items_ = log.items
                itemLog.status_ = log.status?.rawValue
                itemLog.logType_ = log.logType?.rawValue
                itemLog.type_ = log.type?.rawValue
                try self.backgroundContext.save()
            } catch {
                debugPrint("KVKLogger: Could not save data. \(error), \(error.localizedDescription)")
            }
        }
    }

    private func checkOldRecordsAndDeleteIfNeeded() {
        guard isReady else { return }
        debugPrint("KVKLogger: Checking the old records; Last clear date - \(KVKSharedData.shared.lastClearByDate); Auto deleting \(KVKSharedData.shared.clearBy.rawValue).")
        backgroundContext.performAndWait {
            if self.backgroundContext.fetchOldestRecord() != nil,
               KVKSharedData.shared.needToDeleteOldRecords() {
                self.backgroundContext.deleteAll(
                    onlyOldRecords: true,
                    additionalContexts: [self.container.viewContext]
                )
                KVKSharedData.shared.lastClearByDate = Date()
                debugPrint("KVKLogger: The old records was successefully deleted.")
            } else {
                debugPrint("KVKLogger: No need to delete the old records.")
            }
        }
    }

    private let dataBaseURL: URL = {
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        var resultURL: URL
        if #available(iOS 16.0, macOS 13.0, *) {
            resultURL = url?
                .appending(path: "Logs", directoryHint: .isDirectory)
                .appending(path: "com.github.kviatkovskii.kvkloader", directoryHint: .isDirectory) ?? URL(fileURLWithPath: "/dev/null")
        } else {
            resultURL = url?
                .appendingPathComponent("Logs", isDirectory: true)
                .appendingPathComponent("com.github.kviatkovskii.kvkloader", isDirectory: true) ?? URL(fileURLWithPath: "/dev/null")
        }

        if !FileManager.default.fileExists(atPath: resultURL.path) {
            try? FileManager.default.createDirectory(at: resultURL,
                                                     withIntermediateDirectories: true,
                                                     attributes: [:])
        }

        if #available(iOS 16.0, macOS 13.0, *) {
            resultURL = resultURL.appending(component: "consoleDB.sqlite")
        } else {
            resultURL = resultURL.appendingPathComponent("consoleDB.sqlite", isDirectory: false)
        }
        return resultURL
    }()

    private let dbModel: NSManagedObjectModel = {
        typealias Entity = NSEntityDescription
        typealias Attribute = NSAttributeDescription

        let itemLog = Entity(class: ItemLog.self)
        itemLog.properties = [
            Attribute(name: "createdAt_", type: .dateAttributeType),
            Attribute(name: "data_", type: .binaryDataAttributeType),
            Attribute(name: "details_", type: .stringAttributeType),
            Attribute(name: "items_", type: .stringAttributeType),
            Attribute(name: "logType_", type: .stringAttributeType),
            Attribute(name: "status_", type: .stringAttributeType),
            Attribute(name: "type_", type: .stringAttributeType),
        ]
        let model = NSManagedObjectModel()
        model.entities = [itemLog]
        return model
    }()

}

// Safe: dbModel is mutated only during its lazy initializer, then read-only for the process lifetime.
extension NSManagedObjectModel: @unchecked @retroactive Sendable {}

extension NSEntityDescription {
    convenience init<T>(class customClass: T.Type) where T: NSManagedObject {
        self.init()
        name = String(describing: customClass)
        managedObjectClassName = T.description()
    }
}

extension NSAttributeDescription {
    convenience init(name: String,
                     type: NSAttributeType,
                     _ configure: (NSAttributeDescription) -> Void = { _ in }) {
        self.init()
        self.name = name
        attributeType = type
        isOptional = true
        configure(self)
    }
}

extension NSManagedObjectContext {

    func fetchOldestRecord() -> ItemLog? {
        let request = NSFetchRequest<ItemLog>(entityName: ItemLog.entityName)
        request.fetchLimit = 1
        request.sortDescriptors = [NSSortDescriptor(keyPath: \ItemLog.createdAt_, ascending: true)]
        do {
            return try fetch(request).first
        } catch {
            let nsError = error as NSError
            debugPrint("KVKLogger: Unresolved error \(nsError), \(nsError.userInfo)")
            return nil
        }
    }

    /// Batch-deletes all records (or only records older than the configured schedule).
    /// Pass `additionalContexts` to propagate the deletion to other contexts (e.g. viewContext).
    func deleteAll(onlyOldRecords: Bool = false, additionalContexts: [NSManagedObjectContext] = []) {
        do {
            let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: ItemLog.entityName)
            if onlyOldRecords {
                let cutoff = Calendar.current.date(
                    byAdding: .day,
                    value: -KVKSharedData.shared.clearBy.daysInLive,
                    to: Date()
                ) ?? Date()
                fetchRequest.predicate = NSPredicate(format: "createdAt_ < %@", cutoff as NSDate)
            }
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            deleteRequest.resultType = .resultTypeObjectIDs
            let batchDelete = try execute(deleteRequest) as? NSBatchDeleteResult

            guard let deleteResult = batchDelete?.result as? [NSManagedObjectID] else { return }

            let deletedObjects: [String: Any] = [NSDeletedObjectsKey: deleteResult]
            NSManagedObjectContext.mergeChanges(fromRemoteContextSave: deletedObjects,
                                               into: [self] + additionalContexts)
        } catch {
            let nsError = error as NSError
            debugPrint("KVKLogger: Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }

    func saveContext() {
        guard hasChanges else { return }
        performAndWait { [weak self] in
            do {
                try self?.save()
            } catch {
                let nsError = error as NSError
                debugPrint("KVKLogger: Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }

}
