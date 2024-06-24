//
//  KVKLoggerVM.swift
//  
//
//  Created by Sergei Kviatkovskii on 1/29/23.
//

import SwiftUI
import Combine

final class KVKLoggerVM: ObservableObject {
    
    @Published var selectedStatusBy = KVKStatus.none
    @Published var selectedClearBy = KVKSharedData.shared.clearBy
    @Published var isDatePopoverPresented = false
    @Published var query = ""
    @Published var selectedDate: KVKDatePopoverView.DateContainer?
    @Published var sizeOfDB: String?
    // @Published var selectedGroupBy: CurateSubItem = .none
    // @Published var selectedFilterBy: CurateSubItem = .none
    
    var filterBy: String {
        selectedStatusBy.title
    }
    var clearBy: String {
        selectedClearBy.title
    }
    
    private var clearByPublisher: AnyPublisher<SettingSubItem, Never> {
        $selectedClearBy
            .eraseToAnyPublisher()
    }
    private var cancellable = Set<AnyCancellable>()
    
    init() {
        sizeOfDB = KVKLogger.shared.store.dbSize
        clearByPublisher
            .receive(on: DispatchQueue.main)
            .sink { (newValue) in
                KVKSharedData.shared.clearBy = newValue
            }
            .store(in: &cancellable)
    }
    
    deinit {
        cancellable.removeAll()
    }
    
    func getPredicatesBy(query: String? = nil,
                         date: KVKDatePopoverView.DateContainer? = nil,
                         status: KVKStatus? = nil) -> NSPredicate? {
        let queryTmp = query ?? self.query
        let dateTmp = date ?? self.selectedDate
        let statusTmp = status ?? self.selectedStatusBy
        
        var statusPredicate: NSPredicate?
        var itemsPredicate: NSPredicate?
        var detailsPredicate: NSPredicate?
        var logTypePredicate: NSPredicate?
        var typePredicate: NSPredicate?
        
        if !queryTmp.isEmpty && statusTmp != .none {
            statusPredicate = NSPredicate(format: "status_ CONTAINS[cd] %@ AND status_ == %@", queryTmp, statusTmp.rawValue)
            itemsPredicate = NSPredicate(format: "items_ CONTAINS[cd] %@ AND status_ == %@", queryTmp, statusTmp.rawValue)
            detailsPredicate = NSPredicate(format: "details_ CONTAINS[cd] %@ AND status_ == %@", queryTmp, statusTmp.rawValue)
            logTypePredicate = NSPredicate(format: "logType_ CONTAINS[cd] %@ AND status_ == %@", queryTmp, statusTmp.rawValue)
            typePredicate = NSPredicate(format: "type_ CONTAINS[cd] %@ AND status_ == %@", queryTmp, statusTmp.rawValue)
        } else if !queryTmp.isEmpty {
            statusPredicate = NSPredicate(format: "status_ CONTAINS[cd] %@", queryTmp)
            itemsPredicate = NSPredicate(format: "items_ CONTAINS[cd] %@", queryTmp)
            detailsPredicate = NSPredicate(format: "details_ CONTAINS[cd] %@", queryTmp)
            logTypePredicate = NSPredicate(format: "logType_ CONTAINS[cd] %@", queryTmp)
            typePredicate = NSPredicate(format: "type_ CONTAINS[cd] %@", queryTmp)
        } else if statusTmp != .none {
            statusPredicate = NSPredicate(format: "status_ == %@", statusTmp.rawValue)
        }
        
        var predicatesTemp: [NSPredicate] = [statusPredicate,
                                             itemsPredicate,
                                             detailsPredicate,
                                             logTypePredicate,
                                             typePredicate].compactMap { $0 }
        
        if let item = getPredicateByDate(dateTmp) {
            predicatesTemp.append(item)
        }
        guard !predicatesTemp.isEmpty else { return nil }
        
        let predicates = NSCompoundPredicate(orPredicateWithSubpredicates: predicatesTemp)
        return predicates
    }
    
    private func getPredicateByDate(_ date: KVKDatePopoverView.DateContainer?) -> NSPredicate? {
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
    
    private func getPredicateByStatus(_ status: KVKStatus) -> NSPredicate? {
        switch status {
        case .none:
            return nil
        default:
            return NSPredicate(format: "status_ == %@", status.rawValue)
        }
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
                         subItems: [.status]),
         CurateContainer(item: .resetAll)]
    }
    
    func getSettingItems() -> [SettingContainer] {
        [SettingContainer(item: .clearBySchedule,
                          subItems: [.everyDay, .everyWeek, .everyMonth, .everyYear]),
         SettingContainer(item: .clearAll)]
    }
    
}
