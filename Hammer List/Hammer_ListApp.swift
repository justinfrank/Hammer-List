//
//  Hammer_ListApp.swift
//  Hammer List
//
//  Created by Justin Frank on 7/15/25.
//

import SwiftUI
import SwiftData

@main
struct Hammer_ListApp: App {
  @StateObject private var themeManager = ThemeManager()

  var sharedModelContainer: ModelContainer = {
    let schema = Schema([
      Item.self,
      ItemList.self,
    ])
    let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

    do {
        return try ModelContainer(for: schema, configurations: [modelConfiguration])
    } catch {
        fatalError("Could not create ModelContainer: \(error)")
    }
  }()

  var body: some Scene {
      WindowGroup {
          ContentView()
            .environmentObject(themeManager)
            .preferredColorScheme(themeManager.preferredColorScheme)
      }
      .modelContainer(sharedModelContainer)
  }
}
