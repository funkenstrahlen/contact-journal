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
    @StateObject var viewModel = ViewModel()

    var body: some Scene {
        WindowGroup {
            ZStack {
                ContentView()
                CreateItemButton()
            }
            .environment(\.managedObjectContext, persistenceController.container.viewContext)
            .environmentObject(viewModel)
        }
        .onChange(of: scenePhase) { phase in
            switch phase {
            case .active:
                // automatically delete deprecated entries when the user has activated the option
                if UserDefaults.standard.bool(forKey: "shouldAutomaticallyDeleteDeprecatedItems") {
                    PersistenceController.deleteDeprecatedItems()
                }
                if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
                    #if !DEBUG
                    SKStoreReviewController.requestReview(in: scene)
                    #endif
                }
            case .inactive: break
            case .background:
                PersistenceController.saveContext()
            @unknown default: break
            }
        }
    }
}
