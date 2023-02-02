//
//  KVKSharedData.swift
//  
//
//  Created by Sergei Kviatkovskii on 2/2/23.
//

import Foundation

final class KVKSharedData {
        
    static let shared = KVKSharedData()
    
    var isPreviewMode: Bool {
        if let isPreview = ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"], isPreview == "1" {
            return true
        } else {
            return false
        }
    }
    
}
