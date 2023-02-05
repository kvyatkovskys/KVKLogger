//
//  KVKSharedData.swift
//  
//
//  Created by Sergei Kviatkovskii on 2/2/23.
//

import SwiftUI

final class KVKSharedData {
        
    static let shared = KVKSharedData()
    
    @AppStorage("clearBy") private var clearBy_: String?
    @AppStorage("clearByDate") private var clearByDate_: String?
    
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
        }
    }
    
    var clearByDate: Date {
        get {
            guard let dt = clearByDate_ else { return Date() }
            
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy.MM.dd"
            return formatter.date(from: dt) ?? Date()
        }
        set {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy.MM.dd"
            clearByDate_ = formatter.string(from: newValue)
        }
    }
    
}
