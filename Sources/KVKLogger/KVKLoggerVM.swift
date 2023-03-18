//
//  KVKLoggerVM.swift
//  
//
//  Created by Sergei Kviatkovskii on 1/29/23.
//

import SwiftUI

final class KVKLoggerVM: ObservableObject {
    
    @Published var query = ""
    @Published var selectedDate: KVKDatePopoverView.DateContainer?
    // @Published var selectedGroupBy: CurateSubItem = .none
    // @Published var selectedFilterBy: CurateSubItem = .none
    
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
    
    func getPredicatesByDate(_ date: KVKDatePopoverView.DateContainer?) -> NSPredicate? {
        let start = date?.start
        let end = date?.end
        
        if let start, let end {
            return NSPredicate(format: "createdAt_ >= %@ AND createdAt_ < %@", start as NSDate, end as NSDate)
        } else if let start {
            return NSPredicate(format: "createdAt_ >= %@", start as NSDate)
        } else if let end {
            return NSPredicate(format: "createdAt_ < %@", end as NSDate)
        } else {
            return nil
        }
    }
    
    func getPredicateByCurate(_ curate: CurateSubItem) -> NSPredicate? {
//        switch curate {
//        case .status:
//            return NSPredicate(format: "", curate.)
//        case .date:
//            <#code#>
//        case .type:
//            <#code#>
//        default:
            return nil
      //  }
    }
    
    func copyLog(_ log: ItemLog) {
#if os(macOS)
        // in progress
#else
        UIPasteboard.general.string = log.copyTxt
#endif
    }
    
    func getCurateItems() -> [CurateContainer] {
        [CurateContainer(item: .filterBy,
                         subItems: [.status, .type, .date])]
    }
    
    func getSettingItems() -> [SettingContainer] {
        [SettingContainer(item: .clearBySchedule,
                          subItems: [.everyDay, .everyWeek, .everyMonth, .everyYear]),
         SettingContainer(item: .clearAll)]
    }
    
}
