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
    
    public var icon: String {
        switch self {
        case .custom:
            return "🟢"
        case .info:
            return "ℹ️"
        case .error:
            return "❌"
        case .debug:
            return "🔵"
        case .warning:
            return "⚠️"
        case .verbose:
            return "🔍"
        }
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(rawValue)
    }
}

public enum KVKLogType: String {
    case os, debug, print
}

extension ItemLog {
    
    static func fecth() -> NSFetchRequest<ItemLog> {
        let request = NSFetchRequest<ItemLog>(entityName: self.description())
        request.predicate = NSPredicate(value: true)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \ItemLog.createdAt_, ascending: true)]
        return request
    }
    
    static func delete(at offsets: IndexSet, for items: [ItemLog]) {
        if let first = items.first, let context = first.managedObjectContext {
            offsets.map { items[$0] }.forEach(context.delete)
            context.saveContext()
        }
    }
    
    var status: KVKStatus {
        get {
            guard let item = status_ else { return .info }
            return KVKStatus(rawValue: item) ?? .info
        }
        set { status_ = newValue.rawValue }
    }
    
    var type: KVKLogType {
        get {
            guard let item = type_ else { return .debug }
            return KVKLogType(rawValue: item) ?? .debug
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
        createdAt.formatted(date: .abbreviated, time: .complete)
    }
    
    var items: String {
        get {
            items_ ?? ""
        }
        set {
            items_ = newValue
        }
    }
    
}
