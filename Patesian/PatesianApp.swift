//
//  PatesianApp.swift
//  Patesian
//
//  Created by Jimin Lee on 10/10/2023.
//

import SwiftUI

@main
struct PatesianApp: App {
    @Environment(\.scenePhase) var scenePhase
    let persistenceController = PersistenceController.shared
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
