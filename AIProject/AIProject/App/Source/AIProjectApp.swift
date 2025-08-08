//
//  AIProjectApp.swift
//  AIProject
//
//  Created by kangho lee on 7/29/25.
//

import SwiftUI
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
    }
}

@main
struct AIProjectApp: App {
    let persistenceController = PersistenceController.shared
    @AppStorage("hasSeenOnboarding") var hasSeenOnboarding: Bool = false
    
    // register app delegate for Firebase setup
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            if hasSeenOnboarding {
                MainTabView()
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
                    .environmentObject(themeManager)
            } else {
                OnboardingView()
            }
        }
    }
}

