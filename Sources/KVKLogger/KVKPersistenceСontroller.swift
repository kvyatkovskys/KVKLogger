//
//  KVKPersistenceСontroller.swift
//  
//
//  Created by Sergei Kviatkovskii on 1/31/23.
//

import CoreData

struct KVKPersistenceСontroller {
    
    static let shared = KVKPersistenceСontroller()
    
    static var preview: KVKPersistenceСontroller = {
        let result = KVKPersistenceСontroller(inMemory: true)
        let viewContext = result.container.viewContext
        for _ in 0..<10 {
            let newItem = ItemLog(context: viewContext)
            newItem.createdAt_ = Date()
            newItem.status_ = KVKStatus.info.rawValue
            newItem.type_ = KVKLogType.debug.rawValue
//            newItem.details_ = "Test details\nnew line\nfunction"
//            newItem.items_ = "Test description log".data(using: .utf8)
        }
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError),  \(nsError.userInfo)")
        }
        return result
    }()
    
    let container: NSPersistentContainer
    
    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "ConsoleDB")
        if inMemory {
            if #available(iOS 16.0, *) {
                container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
            } else {
                container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.loadPersistentStores { (_, error) in
            if let error = error as? NSError {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
    }
    
}
