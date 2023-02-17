//
//  KVKPersistenceСontroller.swift
//  
//
//  Created by Sergei Kviatkovskii on 1/31/23.
//

import CoreData

struct KVKPersistenceСontroller {
    
    static let shared = KVKPersistenceСontroller()
    
    let container: NSPersistentContainer
    
    var viewContext: NSManagedObjectContext {
        container.viewContext
    }
    
    private let dbName = "consoleDB"
    
    init(inMemory: Bool = false) {
        if inMemory {
            container = NSPersistentContainer(name: dbName, managedObjectModel: KVKPersistenceСontroller.model)
            if #available(iOS 16.0, *) {
                container.persistentStoreDescriptions.first!.url = URL(filePath: "/dev/null")
            } else {
                container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
            }
        } else {
            container = NSPersistentContainer(name: dbName, managedObjectModel: KVKPersistenceСontroller.model)
        }

        let store = NSPersistentStoreDescription(url: dataBaseURL)
        container.persistentStoreDescriptions = [store]
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        container.loadPersistentStores { (desc, error) in
            if let error = error as? NSError {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
    }
    
    func deleteAll() {
        do {
            let fetchRequest: NSFetchRequest<NSFetchRequestResult>
            fetchRequest = NSFetchRequest(entityName: ItemLog.entityName)
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            deleteRequest.resultType = .resultTypeObjectIDs
            let batchDelete = try viewContext.execute(deleteRequest) as? NSBatchDeleteResult

            guard let deleteResult = batchDelete?.result as? [NSManagedObjectID] else { return }

            let deletedObjects: [String: Any] = [NSDeletedObjectsKey: deleteResult]
            NSManagedObjectContext.mergeChanges(fromRemoteContextSave: deletedObjects, into: [viewContext])
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
    
    private var dataBaseURL: URL {
        guard var url = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)
            .first else {
            return URL(fileURLWithPath: "/dev/null")
        }
        
        if #available(iOS 16.0, *) {
            url = url
                .appending(path: "Logs", directoryHint: .isDirectory)
                .appending(path: "com.github.kviatkovskii.kvkloader", directoryHint: .isDirectory)
                .appending(path: UUID().uuidString, directoryHint: .isDirectory)
                .appending(component: dbName, directoryHint: .notDirectory)
        } else {
            url = url
                .appendingPathComponent("Logs", isDirectory: true)
                .appendingPathComponent("com.github.kviatkovskii.kvkloader", isDirectory: true)
                .appendingPathComponent(UUID().uuidString, isDirectory: true)
                .appendingPathComponent(dbName, isDirectory: false)
        }
        
        return url.appendingPathExtension("sqlite")
    }
    
    private static let model: NSManagedObjectModel = {
        typealias Entity = NSEntityDescription
        typealias Attribute = NSAttributeDescription
        // no need right now
//        typealias Relationship = NSRelationshipDescription
        
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
    
    func saveContext() {
        guard hasChanges else { return }
        
        do {
            try save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
    
}
