//
//  AIProjectApp.swift
//  AIProject
//
//  Created by kangho lee on 7/29/25.
//

import SwiftUI

@main
struct AIProjectApp: App {
    let persistenceController = PersistenceController.shared
  @AppStorage("hasSeenOnboarding") var hasSeenOnboarding: Bool = false

    var body: some Scene {
        WindowGroup {
          if hasSeenOnboarding {
            MainTabView()
              .environment(\.managedObjectContext, persistenceController.container.viewContext)
          } else {
            OnboardingView()
          }
        }
    }
}
 
