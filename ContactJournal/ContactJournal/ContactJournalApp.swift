//
//  ContactJournalApp.swift
//  ContactJournal
//
//  Created by Stefan Trauth on 14.10.20.
//

import SwiftUI
import StoreKit

@main
struct ContactJournalApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    let persistenceController = PersistenceController.shared
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
        .onChange(of: scenePhase) { phase in
            switch phase {
            case .active:
                // automatically delete deprecated entries when the user has activated the option
                if UserDefaults.standard.bool(forKey: "shouldAutomaticallyDeleteDeprecatedItems") {
                    PersistenceController.deleteDeprecatedItems()
                }
            case .inactive: break
            case .background:
                PersistenceController.saveContext()
            @unknown default: break
            }
        }
    }
}
