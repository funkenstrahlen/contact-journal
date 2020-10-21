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
                Section(footer: Text("Für die Nachvollziehbarkeit von Infektionen sind alte Einträge nicht mehr relevant. Wenn diese Funktion aktiviert ist, dann werden diese Einträge automatisch aus deinem Kontakt-Tagebuch entfernt.")) {
                    Toggle("Einträge älter als 14 Tage automatisch löschen", isOn: $shouldAutomaticallyDeleteDeprecatedItems)
                }
                Section(footer: Text("Erhalte einmal täglich eine Push Benachrichtigung, die dich daran erinnert dein Kontakt-Tagebuch zu pflegen.")) {
                    Toggle("Push Benachrichtigung zur Erinnerung aktivieren", isOn: $userSettings.shouldSendPushNotification)
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
            NotificationManager.rescheduleNotification()
        }
    }
    
    @Published var notificationTime: Date {
        didSet{
            UserDefaults.standard.set(notificationTime, forKey: "notificationTime")
            NotificationManager.rescheduleNotification()
        }
    }
    
    init() {
        self.shouldSendPushNotification = UserDefaults.standard.bool(forKey: "shouldSendPushNotification")
        self.notificationTime = UserDefaults.standard.object(forKey: "notificationTime") as? Date ?? Date()
    }
}

import os.log

struct NotificationManager {
    private static let log = OSLog(subsystem: "de.stefantrauth.ContactJournal", category: "Notifications")
    
    public static func rescheduleNotification() {
        UNUserNotificationCenter.current().getNotificationSettings { (settings) in
            switch settings.authorizationStatus {
            case .authorized, .provisional, .ephemeral:
                if UserSettings().shouldSendPushNotification {
                    self.scheduleNotification()
                } else {
                    UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["reminder"])
                }
            case .denied: break
            case .notDetermined: self.requestNotificationPermissions()
            @unknown default: break
            }
        }
    }
    
    private static func requestNotificationPermissions() {
        let options: UNAuthorizationOptions = [.alert, .sound, .providesAppNotificationSettings]
        
        UNUserNotificationCenter.current().requestAuthorization(options: options) { (granted, error) in
            if granted {
                self.rescheduleNotification()
            }
        }
    }
    
    private static func scheduleNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Title"
        content.body = "Message"
        content.sound = UNNotificationSound.default
        let notificationTriggerDate = UserSettings().notificationTime
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: Calendar.current.dateComponents([.hour, .minute], from: notificationTriggerDate), repeats: true)
        
        // If you use the same identifier when scheduling a new notification, the system removes the previously scheduled notification with that identifier and replaces it with the new one.
        let request = UNNotificationRequest(identifier: "reminder", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { (error) in
            if error != nil {
                os_log("error scheduling notification: %@", log: log, type: .error, [error?.localizedDescription])
            } else {
                os_log("scheduled notification with request: %@", log: log, type: .debug, [request])
            }
        }
    }
}
