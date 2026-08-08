//
//  KVKLogger.swift
//
//
//  Created by Sergei Kviatkovskii on 1/29/23.
//

import SwiftUI
import CoreData
import OSLog

/// Controls privacy of messages sent to the unified OS logging system.
public enum KVKLogPrivacy {
    /// Log content is visible in Console.app and `log collect` (default, preserves existing behaviour).
    case `public`
    /// Log content is redacted in Console.app to protect sensitive data.
    case `private`
}

public final class KVKLogger: @unchecked Sendable {

    let store: KVKPersistenceСontroller

    public static let shared = KVKLogger()

    private let lock = NSLock()

    // MARK: - Thread-safe public properties

    private var _isDebugMode: Bool?
    /// When set, overrides #DEBUG flag to control console output.
    public var isDebugMode: Bool? {
        get { withLock { _isDebugMode } }
        set { withLock { _isDebugMode = newValue } }
    }

    private weak var _delegate: KVKLoggerDelegate?
    public weak var delegate: KVKLoggerDelegate? {
        get { withLock { _delegate } }
        set { withLock { _delegate = newValue } }
    }

    private var _isEnableSaveIntoDB: Bool = true
    public var isEnableSaveIntoDB: Bool {
        get { withLock { _isEnableSaveIntoDB } }
        set { withLock { _isEnableSaveIntoDB = newValue } }
    }

    private var _logPrivacy: KVKLogPrivacy = .public
    /// Privacy level applied to all OS log messages. Defaults to `.public` for backward compatibility.
    public var logPrivacy: KVKLogPrivacy {
        get { withLock { _logPrivacy } }
        set { withLock { _logPrivacy = newValue } }
    }

    private var _availabeSaveNetworkLogs = true

    private init() {
        store = KVKPersistenceСontroller()
    }

    public func configure(availabeSaveNetworkLogs: Bool = true) {
        withLock { _availabeSaveNetworkLogs = availabeSaveNetworkLogs }
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
                    filename: String = #file,
                    line: Int = #line,
                    funcName: String = #function) {
        var details: String?
        if status == .verbose {
            details = "file: \(sourceFileName(filePath: filename))\nline: \(line)\nfunction: \(funcName)"
        }
        let itemsTxt = items.reduce("") { (acc, item) in acc + "\(item) " }
        handleLog(itemsTxt, type: .common, status: status, logType: type, details: details)
    }

    public func network(_ items: Any...,
                        data: Data? = nil,
                        type: KVKLogType = .os,
                        filename: String? = nil,
                        line: Int? = nil,
                        funcName: String? = nil) {
        var details: String?
        if let filename, let line, let funcName {
            details = "file: \(sourceFileName(filePath: filename))\nline: \(line)\nfunction: \(funcName)"
        }
        let itemsTxt = items.reduce("") { (acc, item) in acc + "\(item) " }
        handleLog(itemsTxt, data: data, type: .network, status: .debug, logType: type, details: details)
    }

    private func handleLog(_ items: String,
                           data: Data? = nil,
                           type: KVKItemLogType,
                           status: KVKStatus = .info,
                           logType: KVKLogType,
                           details: String?) {
        let date = Date()
        let item = ItemLogProxy(createdAt: date,
                                data: data,
                                details: details,
                                items: items,
                                logType: logType,
                                status: status,
                                type: type)

        // Capture mutable state atomically to avoid data races
        let (enableDB, networkLogs, debugMode, privacy, delegateRef) = withLock {
            (_isEnableSaveIntoDB, _availabeSaveNetworkLogs, _isDebugMode, _logPrivacy, _delegate)
        }

        switch type {
        case .common where enableDB:
            store.save(log: item)
        case .network where enableDB && networkLogs:
            store.save(log: item)
        default:
            break
        }

        if let debugMode, debugMode {
            printLog(items, details: details, itemType: type, status: status, type: logType,
                     date: date, privacy: privacy, delegate: delegateRef)
        } else {
#if DEBUG
            printLog(items, details: details, itemType: type, status: status, type: logType,
                     date: date, privacy: privacy, delegate: delegateRef)
#endif
        }
    }

    private func sourceFileName(filePath: String) -> String {
        let components = filePath.components(separatedBy: "/")
        return components.isEmpty ? "" : (components.last ?? "")
    }

    private func printLog(
        _ items: Any,
        details: String? = nil,
        itemType: KVKItemLogType,
        status: KVKStatus,
        type: KVKLogType,
        date: Date,
        privacy: KVKLogPrivacy,
        delegate: KVKLoggerDelegate?
    ) {
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
            status.saveOSLog(txt, type: itemType, privacy: privacy)
            delegate?.didLog(txt, type: itemType)
        case .debug:
            if let details {
                debugPrint(iconWithDate, items, details)
                delegate?.didLog(iconWithDate, items, details, type: itemType)
            } else {
                debugPrint(iconWithDate, items)
                delegate?.didLog(iconWithDate, items, type: itemType)
            }
        case .print:
            if let details {
                print(iconWithDate, items, details)
                delegate?.didLog(iconWithDate, items, details, type: itemType)
            } else {
                print(iconWithDate, items)
                delegate?.didLog(iconWithDate, items, type: itemType)
            }
        }
    }

    @discardableResult
    private func withLock<T>(_ body: () -> T) -> T {
        lock.lock()
        defer { lock.unlock() }
        return body()
    }

}

public protocol KVKLoggerDelegate: AnyObject {
    func didLog(_ items: Any..., type: KVKItemLogType)
}

public extension KVKLoggerDelegate {
    /// Default no-op implementation so conforming types are not required to implement `didLog`.
    func didLog(_ items: Any..., type: KVKItemLogType = .common) {}
}
