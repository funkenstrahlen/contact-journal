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
        ZStack {
            Form {
                Section(footer: Text("Für die Nachvollziehbarkeit von Infektionen sind alte Einträge nicht mehr relevant.")) {
                    Toggle("Einträge älter als 14 Tage automatisch löschen", isOn: $shouldAutomaticallyDeleteDeprecatedItems)
                }
                Section {
                    Toggle("Push Benachrichtigung als Erinnerung aktivieren", isOn: $userSettings.shouldSendPushNotification)
                    if userSettings.shouldSendPushNotification {
                        DatePicker("Uhrzeit", selection: $userSettings.notificationTime, displayedComponents: .hourAndMinute)
                            .datePickerStyle(WheelDatePickerStyle())
                            .labelsHidden()
                            .frame(maxHeight: 100)
                            .clipped()
                    }
                }
            }.navigationBarTitle("Einstellungen")
            VStack {
                Spacer()
                Link("Impressum & Datenschutzerklärung", destination: URL(string: "https://stefantrauth.de/contact-journal-privacy-policy.html")!)
                    .font(.footnote)
                    .padding(.vertical)
            }
        }
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



public class UserSettings: ObservableObject {
    @Published var shouldSendPushNotification: Bool {
        didSet{
            UserDefaults.standard.set(shouldSendPushNotification, forKey: "shouldSendPushNotification")
        }
    }
    
    @Published var notificationTime: Date {
        didSet{
            UserDefaults.standard.set(notificationTime, forKey: "notificationTime")
        }
    }
    
    init() {
        self.shouldSendPushNotification = UserDefaults.standard.bool(forKey: "shouldSendPushNotification")
        self.notificationTime = UserDefaults.standard.object(forKey: "notificationTime") as? Date ?? Date()
    }
}
