//
//  KVKPersistenceСontroller.swift
//  
//
//  Created by Sergei Kviatkovskii on 1/31/23.
//

import CoreData

final class KVKPersistenceСontroller {
        
    let container: NSPersistentContainer
    let backgroundContext: NSManagedObjectContext
    
    var viewContext: NSManagedObjectContext {
        container.viewContext
    }
    
    private let updateContext: NSManagedObjectContext
    private var cacheDBURL: URL?
        
    init(inMemory: Bool = false) {
        let url = dataBaseURL
        cacheDBURL = url
        let dbName = url.lastPathComponent
        if inMemory {
            container = NSPersistentContainer(name: dbName, managedObjectModel: KVKPersistenceСontroller.model)
            if #available(iOS 16.0, macOS 13.0, *) {
                container.persistentStoreDescriptions.first!.url = URL(filePath: "/dev/null")
            } else {
                container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
            }
        } else {
            container = NSPersistentContainer(name: dbName, managedObjectModel: KVKPersistenceСontroller.model)
        }
        
        let store = NSPersistentStoreDescription(url: url)
        container.persistentStoreDescriptions = [store]
        container.loadPersistentStores { (desc, error) in
            if let error = error as? NSError {
                debugPrint("Unresolved error \(error), \(error.userInfo)")
            }
        }
        backgroundContext = container.newBackgroundContext()
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        let _updateContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        _updateContext.parent = container.viewContext
        updateContext = _updateContext
    }
    
    func getNewItem() -> ItemLog? {
        NSEntityDescription.insertNewObject(forEntityName: ItemLog.entityName, into: updateContext) as? ItemLog
    }
    
    func save() {
        // temporary checking a file
        if let url = cacheDBURL, !FileManager.default.fileExists(atPath: url.path) {
            debugPrint("Can't find DB in directory.")
            return
        }
        
        guard updateContext.hasChanges else { return }
        
        updateContext.performAndWait { [weak self] in
            do {
                try self?.updateContext.save()
                self?.viewContext.saveContext()
            } catch {
                debugPrint("Could not save data. \(error), \(error.localizedDescription)")
            }
        }
    }
        
    private let dataBaseURL: URL = {
        let url = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first
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
        
    private static let model: NSManagedObjectModel = {
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
    
    func deleteAll() {
        do {
            let fetchRequest: NSFetchRequest<NSFetchRequestResult>
            fetchRequest = NSFetchRequest(entityName: ItemLog.entityName)
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            deleteRequest.resultType = .resultTypeObjectIDs
            let batchDelete = try execute(deleteRequest) as? NSBatchDeleteResult

            guard let deleteResult = batchDelete?.result as? [NSManagedObjectID] else { return }

            let deletedObjects: [String: Any] = [NSDeletedObjectsKey: deleteResult]
            NSManagedObjectContext.mergeChanges(fromRemoteContextSave: deletedObjects, into: [self])
        } catch {
            let nsError = error as NSError
            debugPrint("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
    
    func saveContext() {
        guard hasChanges else { return }
        
        performAndWait { [weak self] in
            do {
                try self?.save()
            } catch {
                let nsError = error as NSError
                print("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
}
