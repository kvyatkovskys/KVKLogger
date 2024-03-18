//
//  KVKLogger.swift
//  
//
//  Created by Sergei Kviatkovskii on 1/29/23.
//

import SwiftUI
import CoreData
import OSLog

open class KVKLogger: @unchecked Sendable {

    let store: KVKPersistenceСontroller
        
    public static let shared = KVKLogger()
    /// Debug Mode
    /// if #DEBUG isn't setup in a project
    public var isDebugMode: Bool?
    public weak var delegate: KVKLoggerDelegate?
    public var isEnableSaveIntoDB: Bool = true
        
    private init() {
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
        debugPrint("KVKLogger DB: [\(urls)] is configured!")
    }
    
    public func log(_ items: Any...,
                    status: KVKStatus = .info,
                    type: KVKLogType = .os,
                    saveInDB: Bool = true,
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
        handleLog(itemsTxt,
                  type: .common,
                  status: status,
                  logType: type,
                  details: details,
                  saveInDB: saveInDB)
    }
    
    public func network(_ items: Any...,
                        data: Data? = nil,
                        type: KVKLogType = .os,
                        saveInDB: Bool = true,
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
        handleLog(itemsTxt, 
                  data: data,
                  type: .network,
                  status: .debug,
                  logType: type,
                  details: details,
                  saveInDB: saveInDB)
    }
    
    private func handleLog(_ items: String,
                           data: Data? = nil,
                           type: ItemLogType,
                           status: KVKStatus = .info,
                           logType: KVKLogType,
                           details: String?,
                           saveInDB: Bool = true) {
        let date = Date()
        let item = ItemLogProxy(createdAt: date,
                                data: data,
                                details: details,
                                items: items,
                                logType: logType,
                                status: status,
                                type: type)
        
        if isEnableSaveIntoDB && saveInDB {
            store.save(log: item)
        }
        
        if let isDebugMode, isDebugMode {
            printLog(items, details: details, itemType: type, status: status, type: logType, date: date)
        } else {
#if DEBUG
            printLog(items, details: details, itemType: type, status: status, type: logType, date: date)
#endif
        }
    }
    
    private func sourceFileName(filePath: String) -> String {
        let components = filePath.components(separatedBy: "/")
        return components.isEmpty ? "" : (components.last ?? "")
    }
    
    private func printLog(_ items: Any,
                          details: String? = nil,
                          itemType: ItemLogType,
                          status: KVKStatus,
                          type: KVKLogType,
                          date: Date) {
        let iso8601Date = date.formatted(.iso8601)
        let icon = "\(status.icon) "
        let iconWithDate = "\(icon)\(iso8601Date)"
        
        switch type {
        case .os:
            let txt: String
            if let details {
                txt = "\(icon)\(iso8601Date) \(String(describing: items)) \(details)"
            } else {
                txt = "\(icon)\(iso8601Date) \(String(describing: items))"
            }
            status.saveOSLog(txt, type: itemType)
            delegate?.didLog(txt)
        case .debug:
            if let details {
                debugPrint(iconWithDate, items, details)
                delegate?.didLog(iconWithDate, items, details)
            } else {
                debugPrint(iconWithDate, items)
                delegate?.didLog(iconWithDate, items)
            }
        case .print:
            if let details {
                print(iconWithDate, items, details)
                delegate?.didLog(iconWithDate, items, details)
            } else {
                print(iconWithDate, items)
                delegate?.didLog(iconWithDate, items)
            }
        }
    }
    
}

public protocol KVKLoggerDelegate: AnyObject {
    func didLog(_ items: Any...)
}
