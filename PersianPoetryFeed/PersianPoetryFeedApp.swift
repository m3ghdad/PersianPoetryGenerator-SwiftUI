//
//  PersianPoetryFeedApp.swift
//  PersianPoetryFeed
//
//  Created by Meghdad Abbaszadegan on 10/4/25.
//

import SwiftUI
import CoreData

@main
struct PersianPoetryFeedApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
