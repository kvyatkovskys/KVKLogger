//
//  KVKLoggerVM.swift
//  
//
//  Created by Sergei Kviatkovskii on 1/29/23.
//

import SwiftUI

final class KVKLoggerVM: ObservableObject {
    
    @Published var query = ""
    @Published var selectedGroupBy: CurateSubItem?
    
    func getPredicatesByQuery(_ query: String) -> NSPredicate? {
        guard !query.isEmpty else { return nil }
        
        let itemsPredicate = NSPredicate(format: "items_ CONTAINS[cd] %@", query)
        let detailsPredicate = NSPredicate(format: "details_ CONTAINS[cd] %@", query)
        let logTypePredicate = NSPredicate(format: "logType_ CONTAINS[cd] %@", query)
        let typePredicate = NSPredicate(format: "type_ CONTAINS[cd] %@", query)
        let statusPredicate = NSPredicate(format: "status_ CONTAINS[cd] %@", query)
        let predicates = NSCompoundPredicate(orPredicateWithSubpredicates: [
            itemsPredicate,
            detailsPredicate,
            logTypePredicate,
            statusPredicate,
            typePredicate
        ])
        return predicates
    }
    
    func copyLog(_ log: ItemLog) {
        UIPasteboard.general.string = log.copyTxt
    }
    
    func getCurateItems() -> [CurateContainer] {
        [CurateContainer(item: .groupBy,
                         subItems: CurateSubItem.allCases)]
    }
    
    func getSettingItems() -> [SettingContainer] {
        [SettingContainer(item: .clearBySchedule,
                          subItems: SettingSubItem.allCases),
         SettingContainer(item: .clearAll)]
    }
    
}
