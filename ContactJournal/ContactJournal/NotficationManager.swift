//
//  NotficationManager.swift
//  ContactJournal
//
//  Created by Stefan Trauth on 21.10.20.
//

import Foundation
import UserNotifications
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
