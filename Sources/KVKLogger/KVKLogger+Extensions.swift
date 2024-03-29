//
//  KVKLogger+Extensions.swift
//  
//
//  Created by Sergei Kviatkovskii on 1/29/23.
//

import Foundation
import OSLog

extension Logger: @unchecked Sendable {
    private static let subsystem = Bundle.main.bundleIdentifier ?? "kvk.logger.com"

    static let logs = Logger(subsystem: subsystem, category: "logs")
    static let networks = Logger(subsystem: subsystem, category: "networks")
}
