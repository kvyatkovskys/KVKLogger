//
//  KVKLogger.swift
//  
//
//  Created by Sergei Kviatkovskii on 1/29/23.
//

import SwiftUI

open class KVKLogger {
    
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
        
        let date = Date()
//        let item = ItemLog(status: status, type: type, items: items, date: date, details: details)
//        vm.logs.append(item)
        
        if isDebugMode != false {
            printLog(items, details: details, status: status, type: type, date: date)
        } else {
#if DEBUG
        printLog(items, details: details, status: status, type: type, date: date)
#endif
        }
    }
    
    private func sourceFileName(filePath: String) -> String {
        let components = filePath.components(separatedBy: "/")
        return components.isEmpty ? "" : components.last!
    }
    
    private func printLog(_ items: Any...,
                          details: String? = nil,
                          status: KVKStatus,
                          type: KVKLogType,
                          date: Date) {
        let iso8601Date = date.formatted(.iso8601)
        switch type {
        case .os:
            break
        case .debug:
            if let details {
                debugPrint("\(status.icon) \(iso8601Date)", items, details)
            } else {
                debugPrint("\(status.icon) \(iso8601Date)", items)
            }
        case .print:
            if let details {
                print("\(status.icon) \(iso8601Date)", items, details)
            } else {
                print("\(status.icon) \(iso8601Date)", items)
            }
        }
    }
    
}
