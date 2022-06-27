//
//  idk.swift
//  DaysSince
//
//  Created by Vicki Minerva on 3/30/22.
//

import Foundation
import SwiftUI
import UserNotifications


struct DaysSinceItem: Identifiable, Codable {

    let id: UUID = UUID()

    /// The name of the item.
    var name: String
    
    /// Category of the item.
    var category = CategoryDaysSinceItem.work
    
    /// Day last done.
    var dateLastDone: Date

    // Whether the item sends reminders.
    var getReminders: Bool
    
    // What type of reminder (daily, weekly, monthly)
    var reminder: DSItemReminders = .none
    
    // Date when item was completed.
    var dateCompleted: Date = Date.now
    
    /// The emoji of the item.
    var emoji: String {
        return category.emoji
    }
    

    /// String for number of days since you did it.
    var daysAgo: Int {
        let daysSince = Calendar.current.numberOfDaysBetween(dateLastDone, and: Date.now)
        return abs(daysSince)
    }
    
    var completedDaysAgo: Int {
        let daysSince = Calendar.current.numberOfDaysBetween(dateCompleted, and: Date.now)
        return abs(daysSince)
    }

    static func placeholderItem() -> DaysSinceItem {
        return DaysSinceItem(name: "Placeholder", category: CategoryDaysSinceItem.hobbies, dateLastDone: Date.now, getReminders: false)
    }
    
    func addReminder() {
        let center = UNUserNotificationCenter.current()
        
        let addNotification = {
            let content = UNMutableNotificationContent()
            content.title = "\(self.name)"
            content.subtitle = "It's been \(self.daysAgo) days!"
            content.sound = UNNotificationSound.default

            var dateComponents = DateComponents()
            if self.reminder == .none {
                // FIX
                return
            }else if self.reminder == .daily {
                dateComponents.hour = 10
                dateComponents.minute = 0
            } else if self.reminder == .weekly {
                dateComponents.weekday = 1
                dateComponents.hour = 10
                dateComponents.second = 0
            } else if self.reminder == .monthly {
                dateComponents.day = 1
                dateComponents.weekday = 1
                dateComponents.hour = 10
                dateComponents.minute = 0
            }
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
            // For testing send trigger every 5 seconds.
//            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)

            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
            center.add(request)
            print(dateComponents)
        }

        center.getNotificationSettings { settings in
            if settings.authorizationStatus == .authorized {
                addNotification()
                print("🔔 Added notification!")
            } else {
                center.requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
                    if success {
                        addNotification()
                        print("🔔 Added notification!")
                    } else {
                        print("Didn't authorize notifications")
                    }
                }
            }
        }
    }
    
}
