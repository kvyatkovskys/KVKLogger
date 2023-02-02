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
    
    private let dbName = "ConsoleDB"
    
    init(inMemory: Bool = false) {
        guard let url = Bundle.module.url(forResource: dbName, withExtension: "momd") else {
            fatalError("Could not get URL for model: \(dbName)")
        }
        guard let model = NSManagedObjectModel(contentsOf: url) else {
            fatalError("Could not get model for: \(url)")
        }
        container = NSPersistentContainer(name: dbName, managedObjectModel: model)
        if inMemory {
            if #available(iOS 16.0, *) {
                container.persistentStoreDescriptions.first!.url = URL(filePath: "/dev/null")
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
