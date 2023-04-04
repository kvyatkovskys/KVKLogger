//
//  KVKLogger.swift
//  
//
//  Created by Sergei Kviatkovskii on 1/29/23.
//

import SwiftUI
import CoreData

open class KVKLogger {

    let store: KVKPersistenceСontroller
    
    public static let shared = KVKLogger()
    /// Debug Mode
    /// if #DEBUG isn't setup in a project
    public var isDebugMode: Bool?
    
    public var isEnableSaveIntoDB: Bool = true
    
    @ObservedObject var vm = KVKLoggerVM()
    
    public init() {
        store = KVKPersistenceСontroller()
    }
    
    public func configure() {
        let urls = store.container.persistentStoreDescriptions
            .compactMap({ $0.url?.lastPathComponent })
            .joined(separator: ", ")
        if urls.isEmpty {
            debugPrint("Problem with configuring local DB!")
            return
        }
        debugPrint("Local DB: [\(urls)] is configured!")
    }
    
    public func log(_ items: Any...,
                    status: KVKStatus = .info,
                    type: KVKLogType = .print,
                    filename: String = #file,
                    line: Int = #line,
                    funcName: String = #function) {
        var details: String?
        if status == .verbose {
            details = "file: \(sourceFileName(filePath: filename))\nline: \(line)\nfunction: \(funcName)"
        }
        let itemsTxt = items.reduce("") { (acc, item) in
            acc + "\(item) "
        }
        handleLog(itemsTxt, type: .common, status: status, logType: type, details: details)
    }
    
    public func network(_ items: Any...,
                        data: Data? = nil,
                        type: KVKLogType = .print,
                        filename: String? = nil,
                        line: Int? = nil,
                        funcName: String? = nil) {
        var details: String?
        if let filename, let line, let funcName {
            details = "file: \(sourceFileName(filePath: filename))\nline: \(line)\nfunction: \(funcName)"
        }
        let itemsTxt = items.reduce("") { (acc, item) in
            acc + "\(item) "
        }
        handleLog(itemsTxt, data: data, type: .network, status: .debug, logType: type, details: details)
    }
    
    private func handleLog(_ items: String,
                           data: Data? = nil,
                           type: ItemLogType,
                           status: KVKStatus? = nil,
                           logType: KVKLogType,
                           details: String?) {
        let date = Date()
        if isEnableSaveIntoDB {
            let item = ItemLogProxy(createdAt: date,
                                    data: data,
                                    details: details,
                                    items: items,
                                    logType: logType,
                                    status: status ?? .info,
                                    type: type)
            store.save(log: item)
        }
        
        if isDebugMode != false {
            printLog(items, details: details, status: status, type: logType, date: date)
        } else {
#if DEBUG
        printLog(items, details: details, status: status, type: logType, date: date)
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
