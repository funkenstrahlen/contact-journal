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
    
    var body: some View {
        ZStack {
            Form {
                Section(footer: Text("Für die Nachvollziehbarkeit von Infektionen sind alte Einträge nicht mehr relevant.")) {
                    Toggle("Einträge älter als 14 Tage automatisch löschen", isOn: $shouldAutomaticallyDeleteDeprecatedItems)
                }
            }.navigationBarTitle("Einstellungen")
            VStack {
                Spacer()
                Link("Impressum & Datenschutzerklärung", destination: URL(string: "https://stefantrauth.de/contact-journal-privacy-policy.html")!)
                    .font(.footnote)
            }
        }
    }
}

struct Settings_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            Settings()
        }
        
    }
}
