//
//  DemoLoggerApp.swift
//  DemoLogger
//
//  Created by Sergei Kviatkovskii on 1/29/23.
//

import SwiftUI
import KVKLogger

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        let sceneConfiguration = UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
        sceneConfiguration.delegateClass = SceneDelegate.self
        return sceneConfiguration
    }
}

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
}

@main
struct DemoLoggerApp: App {
        
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .task {
                    KVKLogger.shared.configure()
                }
        }
    }
    
}
