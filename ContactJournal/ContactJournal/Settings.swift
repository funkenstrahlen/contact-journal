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
        Form {
            Toggle("Einträge älter als 14 Tage automatisch löschen", isOn: $shouldAutomaticallyDeleteDeprecatedItems)
        }.navigationBarTitle("Einstellungen")
    }
}
