//
//  Settings.swift
//  ContactJournal
//
//  Created by Stefan Trauth on 16.10.20.
//

import Foundation
import SwiftUI

struct Settings: View {
    @AppStorage("shouldAutomaticallyDeleteDeprecatedItems") var shouldAutomaticallyDeleteDeprecatedItems: Bool = false
    @StateObject var userSettings = UserSettings()
    
    var body: some View {
        Form {
            Section(footer: Text("Für die Nachvollziehbarkeit von Infektionen sind alte Einträge nicht mehr relevant. Wenn diese Funktion aktiviert ist, dann werden diese Einträge automatisch aus deinem Kontakt-Tagebuch entfernt.")) {
                Toggle("Einträge älter als 3 Wochen automatisch löschen", isOn: $shouldAutomaticallyDeleteDeprecatedItems)
            }
            Section(footer: Text("Erhalte einmal täglich eine Push Benachrichtigung, die dich daran erinnert dein Kontakt-Tagebuch zu pflegen.")) {
                Toggle("Erinnerung als Push Benachrichtigung", isOn: $userSettings.shouldSendPushNotification)
                if userSettings.shouldSendPushNotification {
                    DatePicker("Uhrzeit", selection: $userSettings.notificationTime, displayedComponents: .hourAndMinute)
                        .datePickerStyle(WheelDatePickerStyle())
                        .labelsHidden()
                        .frame(maxHeight: 100)
                        .clipped()
                }
            }
            Section {
                Link("Impressum & Datenschutzerklärung", destination: URL(string: "https://stefantrauth.de/contact-journal-privacy-policy.html")!)
            }
        }.navigationBarTitle("Einstellungen")
    }
}

struct Settings_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            NavigationView {
                Settings()
            }
            .previewDevice("iPhone 8")
            NavigationView {
                Settings()
            }
        }
        
    }
}
