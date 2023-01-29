//
//  KVKModels.swift
//  
//
//  Created by Sergei Kviatkovskii on 1/29/23.
//

import SwiftUI

public enum KVKStatus: Identifiable {
    case info, error, debug, warning, verbose
    /// custom error entity
    /// parameters:
    /// - name: name of error
    /// - color: color of error
    case custom(_ name: String, _ color: UIColor)
    
    public var id: Int {
        switch self {
        case .custom:
            return 0
        case .info:
            return 1
        case .error:
            return 2
        case .debug:
            return 3
        case .warning:
            return 4
        case .verbose:
            return 5
        }
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
}
