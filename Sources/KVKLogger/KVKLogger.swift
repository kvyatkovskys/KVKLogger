//
//  KVKLogger.swift
//  
//
//  Created by Sergei Kviatkovskii on 1/29/23.
//

import SwiftUI
import CoreData

open class KVKLogger {

    private let viewContext = KVKPersistenceСontroller.shared.viewContext
    
    public static let shared = KVKLogger()
    /// Debug Mode
    /// if #DEBUG isn't setup in a project
    public var isDebugMode: Bool?
    
    @ObservedObject var vm = KVKLoggerVM()
    
    public func log(_ items: Any...,
                    status: KVKStatus = .info,
                    type: KVKLogType = .debug,
                    filename: String = #file,
                    line: Int = #line,
                    funcName: String = #function) {
        var details: String?
        if status == .verbose {
            details = "file: \(sourceFileName(filePath: filename))\nline: \(line)\nfunction: \(funcName)"
        }
        let itemsTxt = items.reduce("") { (acc, item) in
            acc + " " + String(describing: item)
        }
        handleLog(itemsTxt, originalItems: items, type: .common, status: status, logType: type, details: details)
    }
    
    public func network(_ items: Any...,
                        data: Data? = nil,
                        type: KVKLogType = .debug,
                        filename: String? = nil,
                        line: Int? = nil,
                        funcName: String? = nil) {
        var details: String?
        if let filename, let line, let funcName {
            details = "file: \(sourceFileName(filePath: filename))\nline: \(line)\nfunction: \(funcName)"
        }
        let itemsTxt = items.reduce("") { (acc, item) in
            acc + " " + String(describing: item)
        }
        handleLog(itemsTxt, originalItems: items, data: data, type: .network, logType: type, details: details)
    }
    
    private func handleLog(_ items: String,
                           originalItems: Any,
                           data: Data? = nil,
                           type: ItemLogType,
                           status: KVKStatus? = nil,
                           logType: KVKLogType,
                           details: String?) {
        let date = Date()
        let item = ItemLog(context: viewContext)
        item.createdAt = date
        item.status_ = status?.rawValue
        item.logType = logType
        item.type = type
        item.details = details
        item.items = items
        item.data = data
        viewContext.saveContext()
        
        if isDebugMode != false {
            printLog(originalItems, details: details, status: status, type: logType, date: date)
        } else {
#if DEBUG
        printLog(originalItems, details: details, status: status, type: logType, date: date)
#endif
        }
    }
    
    private func sourceFileName(filePath: String) -> String {
        let components = filePath.components(separatedBy: "/")
        return components.isEmpty ? "" : (components.last ?? "")
    }
    
    private func printLog(_ items: Any,
                          details: String? = nil,
                          status: KVKStatus?,
                          type: KVKLogType,
                          date: Date) {
        let iso8601Date = date.formatted(.iso8601)
        let icon: String
        if let status {
            icon = "\(status.icon) "
        } else {
            icon = ""
        }
        
        switch type {
        case .os:
            break
        case .debug:
            if let details {
                debugPrint("\(icon)\(iso8601Date)", items, details)
            } else {
                debugPrint("\(icon)\(iso8601Date)", items)
            }
        case .print:
            if let details {
                print("\(icon)\(iso8601Date)", items, details)
            } else {
                print("\(icon)\(iso8601Date)", items)
            }
        }
    }
    
}
