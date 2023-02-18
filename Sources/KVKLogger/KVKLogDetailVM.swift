//
//  KVKLogDetailVM.swift
//  
//
//  Created by Sergei Kviatkovskii on 2/18/23.
//

import SwiftUI
import CoreData

final class KVKLogDetailVM: ObservableObject {
    
    @Published var text = ""
    @Published var size: String?
    @Published var json = ""
    @Published var isLoading = false
    @Published var title = ""
    
    private let id: NSManagedObjectID
    private let backgroundContext = KVKPersistenceСontroller.shared.backgroundContext
    private var dataIsLoaded = false
    private var copyTxt = ""
    
    init(id: NSManagedObjectID) {
        self.id = id
    }
    
    func copy() {
        // in progress
        UIPasteboard.general.string = copyTxt
    }
    
    func fetchObjectIfNeeded() {
        guard !dataIsLoaded else { return }
        
        isLoading = true
        backgroundContext.perform { [weak self] in
            if let ID = self?.id, let item = try? self?.backgroundContext.existingObject(with: ID) as? ItemLog {
                self?.text = item.items
                self?.size = item.size
                self?.title = item.formattedShortCreatedAt
                self?.copyTxt = item.copyTxt
                do {
                    self?.json = try item.getNetworkJson()
                } catch {
                    self?.json = error.localizedDescription
                }
            }
            self?.isLoading = false
            self?.dataIsLoaded = true
        }
    }
    
}
