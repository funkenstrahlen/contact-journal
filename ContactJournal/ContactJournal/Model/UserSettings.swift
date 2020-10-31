//
//  UserSettings.swift
//  ContactJournal
//
//  Created by Stefan Trauth on 21.10.20.
//

import Foundation
import Combine

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
