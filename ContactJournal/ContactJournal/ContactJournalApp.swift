//
//  ContactJournalApp.swift
//  ContactJournal
//
//  Created by Stefan Trauth on 14.10.20.
//

import SwiftUI

@main
struct ContactJournalApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
    
    init() {
        // automatically delete deprecated entries when the user has activated the option
        if UserDefaults.standard.bool(forKey: "shouldAutomaticallyDeleteDeprecatedItems") {
            PersistenceController.deleteDeprecatedItems()
        }
    }
}
