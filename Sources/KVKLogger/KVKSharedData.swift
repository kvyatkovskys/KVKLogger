//
//  KVKSharedData.swift
//  
//
//  Created by Sergei Kviatkovskii on 2/2/23.
//

import SwiftUI

final class KVKSharedData: @unchecked Sendable {
        
    static let shared = KVKSharedData()
        
    @AppStorage("clearBy") private var clearBy_: String?
    @AppStorage("clearByDate") private var lastClearByDate_: String?
    
    var isPreviewMode: Bool {
        if let isPreview = ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"], isPreview == "1" {
            return true
        } else {
            return false
        }
    }
    
    var clearBy: SettingSubItem {
        get {
            guard let item = clearBy_ else { return .everyWeek }
            return SettingSubItem(rawValue: item) ?? .everyWeek
        }
        set {
            clearBy_ = newValue.rawValue
            lastClearByDate = Date()
        }
    }
    
    var lastClearByDate: Date {
        get {
            guard let dt = lastClearByDate_ else { return Date() }
            
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy.MM.dd"
            return formatter.date(from: dt) ?? Date()
        }
        set {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy.MM.dd"
            lastClearByDate_ = formatter.string(from: newValue)
        }
    }
    
    func needToDeleteOldRecords(from date: Date) -> Bool {
        let fromDate = Calendar.current.startOfDay(for: date)
        let toDate = Calendar.current.startOfDay(for: lastClearByDate)
        let days = Calendar.current.dateComponents([.day],
                                                   from: fromDate,
                                                   to: toDate).day ?? 0
        switch clearBy {
        case .everyDay, .everyWeek, .everyMonth, .everyYear:
            return days >= clearBy.daysInLive
        case .none:
            return false
        }
    }
    
    private init() {
        if clearBy_ == nil {
            clearBy = .everyWeek
        }
    }
    
}
