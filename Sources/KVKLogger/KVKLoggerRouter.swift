//
//  KVKLoggerRouter.swift
//  
//
//  Created by Sergei Kviatkovskii on 1/29/23.
//

import SwiftUI

#if os(iOS)

import UIKit

public protocol KVKLoggerRouter {}

public extension KVKLoggerRouter where Self: UIViewController {
    
    func presentToKVKLogger() {
        let vc = createKVKLoggerController()
        present(vc, animated: true)
    }
    
    func pushToKVKLogger() {
        guard let vc = createKVKLoggerController().navigationController?.viewControllers.first else { return }
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func createKVKLoggerController() -> UIHostingController<KVKLoggerView> {
        let vc = UIHostingController(rootView: KVKLoggerView())
        return vc
    }
    
}

#endif
