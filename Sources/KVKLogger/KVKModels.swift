//
//  KVKModels.swift
//  
//
//  Created by Sergei Kviatkovskii on 1/29/23.
//

import SwiftUI
import CoreData

#if os(iOS)
import UIKit
#endif

public enum KVKStatus: Identifiable, Hashable, RawRepresentable {
    case info, error, debug, warning, verbose
    /// custom error entity
    /// parameters:
    /// - name: name of error
    /// - color: color of error
    case custom(_ name: String)
    
    public typealias RawValue = String
    
    public init?(rawValue: String) {
        switch rawValue.lowercased() {
        case "info":
            self = .info
        case "error":
            self = .error
        case "debug":
            self = .debug
        case "warning":
            self = .warning
        case "verbose":
            self = .verbose
        default:
            self = .custom(rawValue)
        }
    }
    
    public var rawValue: String {
        switch self {
        case .info:
            return "info"
        case .error:
            return "error"
        case .debug:
            return "debug"
        case .warning:
            return "warning"
        case .verbose:
            return "verbose"
        case .custom(let txt):
            return txt.lowercased()
        }
    }
    
    public var id: KVKStatus {
        self
    }
    
    public var title: String {
        switch self {
        case .custom(let txt):
            return txt.capitalized
        case .info:
            return "Info"
        case .error:
            return "Error"
        case .debug:
            return "Debug"
        case .warning:
            return "Warning"
        case .verbose:
            return "Verbose"
        }
    }
    
#if os(iOS)
    public var color: UIColor {
        switch self {
        case .custom:
            return .systemOrange
        case .info:
            return .systemBlue
        case .error:
            return .systemRed
        case .debug:
            return .systemPurple
        case .warning:
            return .systemYellow
        case .verbose:
            return .systemTeal
        }
    }
#endif
    
    public var icon: String {
        switch self {
        case .custom:
            return "????"
        case .info:
            return "??????"
        case .error:
            return "???"
        case .debug:
            return "????"
        case .warning:
            return "??????"
        case .verbose:
            return "????"
        }
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(rawValue)
    }
}

public enum KVKLogType: String {
    case os, debug, print
}

// MARK: available in module

enum SettingItem: Int, Identifiable {
    case clearAll, clearBySchedule
    
    var id: Int {
        rawValue
    }
    
    var title: String {
        switch self {
        case .clearAll:
            return "Clear All"
        case .clearBySchedule:
            return "Clear by schedule"
        }
    }
    
    var tint: Color {
        switch self {
        case .clearAll:
            return .red
        case .clearBySchedule:
            return .black
        }
    }
}

enum SettingSubItem: String, Identifiable, CaseIterable {
    case everyDay, everyWeek, everyMonth, everyYear, none
    
    var id: SettingSubItem {
        self
    }
    
    var title: String {
        switch self {
        case .everyDay:
            return "Every day"
        case .everyWeek:
            return "Every week"
        case .everyMonth:
            return "Every month"
        case .everyYear:
            return "Every year"
        case .none:
            return "None"
        }
    }
}

struct SettingContainer: Identifiable {
    let item: SettingItem
    var subItems: [SettingSubItem]?
    
    var id: Int {
        item.id
    }
}

enum ItemLogType: String {
    case network, common
}

enum CurateItem: Int, Identifiable {
    case groupBy, filterBy
    
    var id: Int {
        rawValue
    }
    
    var title: String {
        switch self {
        case .filterBy:
            return "Filter by:"
        case .groupBy:
            return "Group by:"
        }
    }
}

enum CurateSubItem: String, Identifiable, CaseIterable {
    case status, date, type, reset
    
    var id: CurateSubItem {
        self
    }
    
    var title: String {
        switch self {
        case .status:
            return "Status"
        case .date:
            return "Date"
        case .type:
            return "Type"
        case .reset:
            return "Reset"
        }
    }
}

struct CurateContainer: Identifiable {
    let item: CurateItem
    let subItems: [CurateSubItem]
    
    var id: Int {
        item.id
    }
}

final class ItemLog: NSManagedObject {
    
    @NSManaged var createdAt_: Date?
    @NSManaged var data_: Data?
    @NSManaged var details_: String?
    @NSManaged var items_: String?
    @NSManaged var logType_: String?
    @NSManaged var status_: String?
    @NSManaged var type_: String?
}

extension ItemLog: Identifiable {
    
    var id: NSManagedObjectID { objectID }
    
}

extension ItemLog {
    
    static var entityName: String {
        "\(ItemLog.self)"
    }
    
    static func fecth() -> NSFetchRequest<ItemLog> {
        let request = NSFetchRequest<ItemLog>(entityName: entityName)
        request.predicate = NSPredicate(value: true)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \ItemLog.createdAt_, ascending: false)]
        return request
    }
    
    static func delete(at offsets: IndexSet, for items: [ItemLog]) {
        if let first = items.first, let context = first.managedObjectContext {
            offsets.map { items[$0] }.forEach(context.delete)
            context.saveContext()
        }
    }
    
    func delete(for item: ItemLog) {
        let context = item.managedObjectContext
        context?.delete(item)
        context?.saveContext()
    }
    
    var status: KVKStatus {
        get {
            guard let item = status_ else { return .info }
            return KVKStatus(rawValue: item) ?? .info
        }
        set { status_ = newValue.rawValue }
    }
    
    var logType: KVKLogType {
        get {
            guard let item = logType_ else { return .debug }
            return KVKLogType(rawValue: item) ?? .debug
        }
        set { logType_ = newValue.rawValue }
    }
    
    var type: ItemLogType {
        get {
            guard let item = type_ else { return .common }
            return ItemLogType(rawValue: item) ?? .common
        }
        set { type_ = newValue.rawValue }
    }
    
    var createdAt: Date {
        get { createdAt_ ?? Date() }
        set { createdAt_ = newValue }
    }
    
    var details: String? {
        get { details_ }
        set { details_ = newValue }
    }
    
    var formattedCreatedAt: String {
        if #available(iOS 15.0, macOS 12.0, *) {
            return createdAt.formatted(date: .abbreviated, time: .complete)
        } else {
            return "in-progress"
        }
    }
    
    var formattedShortCreatedAt: String {
        if #available(iOS 15.0, macOS 12.0, *) {
            return createdAt.formatted(date: .abbreviated, time: .shortened)
        } else {
            return "in-progress"
        }
    }
    
    var items: String {
        get { items_ ?? "" }
        set { items_ = newValue }
    }
    
    var data: Data? {
        get { data_ }
        set { data_ = newValue }
    }
    
    var size: String? {
        guard let data else { return nil }
        
        let bcf = ByteCountFormatter()
        bcf.allowedUnits = [.useMB, .useBytes, .useKB]
        bcf.countStyle = .file
        return bcf.string(fromByteCount: Int64(data.count))
    }
    
    func getNetworkJson() throws -> String {
        guard let dt = data else { return "" }
        
        guard let json = try? JSONSerialization.jsonObject(with: dt, options: [.mutableLeaves]) else {
            return String(data: dt, encoding: .utf8) ?? ""
        }
        return "\(json)"
    }
    
    var copyTxt: String {
        return items + "\n" + (details ?? "")
    }
    
}
