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
    var remindersEnabled: Bool
    
    // What type of reminder (daily, weekly, monthly)
    var reminder: DSItemReminders = .daily
    
    // Date when item was completed.
    var dateCompleted: Date = Date.now
    
    /// The emoji of the item.
    var emoji: String {
        return category.emoji
    }
    
    /// The ID of the repeating notification reminder.
    var reminderNotificationID: String = UUID().uuidString
        

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
        return DaysSinceItem(name: "Placeholder", category: CategoryDaysSinceItem.hobbies, dateLastDone: Date.now, remindersEnabled: false)
    }
    
    func addReminder() {
        let center = UNUserNotificationCenter.current()
        
        let content = UNMutableNotificationContent()
        
        content.title = "\(self.name)"
//            content.subtitle = "It's been \(self.daysAgo) days since \(self.name)!"
        content.body = "It's been \(self.daysAgo) days since \(self.name)!"
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
            
//            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
            // For testing send trigger every 60 seconds.
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 60, repeats: true)
        
        print("Our ID is \(reminderNotificationID)")
        let request = UNNotificationRequest(identifier: self.reminderNotificationID, content: content, trigger: trigger)
        
        center.getNotificationSettings { settings in
            if settings.authorizationStatus == .authorized {
                center.add(request)
                print("🔔 Added notification!")
                print("the request is: \(request)")
            } else {
                center.requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
                    if success {
                        center.add(request)
                        print("🔔 Added notification!")
                        print("the request is: \(request)")

                    } else {
                        print("Didn't authorize notifications")
                    }
                }
            }
        }
    }
    
    func deleteReminders() {
        
        let center = UNUserNotificationCenter.current()
        
//        center.removePendingNotificationRequests(withIdentifiers: [self.reminderNotificationID])
        
        center.getPendingNotificationRequests { (reqs) in

           var ids =  [String]()

           reqs.forEach {
               if $0.identifier == self.reminderNotificationID {
                  ids.append($0.identifier)
               }
           }
            print("List is \(ids)")
            center
                .removePendingNotificationRequests(withIdentifiers:ids)
        }
    }
    
}
