//
//  DemoLoggerApp.swift
//  DemoLogger
//
//  Created by Sergei Kviatkovskii on 1/29/23.
//

import SwiftUI
import KVKLogger

#if os(iOS)
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
#endif

@main
struct DemoLoggerApp: App {
    
#if os(iOS)
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
#endif
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .task {
                    KVKLogger.shared.configure()
                }
#if os(macOS)
                .presentedWindowStyle(.hiddenTitleBar)
                .presentedWindowToolbarStyle(.unifiedCompact)
                .frame(width: 500, height: 600)
#endif
        }
    }
    
}
