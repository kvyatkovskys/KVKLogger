//
//  KVKModels.swift
//  
//
//  Created by Sergei Kviatkovskii on 1/29/23.
//

import SwiftUI

public enum KVKStatus: Identifiable, Hashable {
    case info, error, debug, warning, verbose
    /// custom error entity
    /// parameters:
    /// - name: name of error
    /// - color: color of error
    case custom(_ name: String, _ color: UIColor)
    
    public var id: KVKStatus {
        self
    }
    
    public var title: String {
        switch self {
        case .custom(let txt, _):
            return txt
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
        case .custom(_, let value):
            return value
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
            return "🟢:"
        case .info:
            return "ℹ️:"
        case .error:
            return "❌:"
        case .debug:
            return "🔵:"
        case .warning:
            return "⚠️:"
        case .verbose:
            return "🔍:"
        }
    }
}

public enum KVKLogType: Int {
    case os, debug, print
}

struct ItemLog: Equatable {
    var status: KVKStatus
    var type: KVKLogType
    var items: Any
    var date: Date
    var details: String?
    
    var formattedDate: String {
        date.formatted(date: .abbreviated, time: .complete)
    }
    
    var formattedTxt: String {
        String(describing: items)
    }
    
    static func == (lhs: ItemLog, rhs: ItemLog) -> Bool {
        lhs.date == rhs.date
        && lhs.status == rhs.status
    }
    
}
