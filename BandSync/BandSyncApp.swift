//
//  BandSyncApp.swift
//  BandSync
//
//  Created by Oleksandr Kuziakin on 25.02.2025.
//

import SwiftUI

@main
struct BandSyncApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
