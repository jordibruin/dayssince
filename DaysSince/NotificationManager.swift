//
//  NotificationManager.swift
//  DaysSince
//
//  Created by Jordi Bruin on 01/07/2022.
//

import Foundation
import UserNotifications

class NotificationManager: ObservableObject {
    
    let center = UNUserNotificationCenter.current()
    
    @Published var pendingNotifications: [UNNotificationRequest] = []
    
    func getPendingNotification() {
        center.getPendingNotificationRequests { requests in
            
            DispatchQueue.main.async(execute: {
                // if there are none we stop
                guard !requests.isEmpty else {
                    print("No notification requests")
                    self.pendingNotifications = []
                    return
                }
                
                self.pendingNotifications = requests
                print("Notification requests open")
            })
            
            // how do we print each request in requests ?
            
            for request in requests {
                print(request.identifier)
                print(request.content.title)
                print(request.content.body)
            }
        }
    }
    
    @Published var notificationPermissionGiven = true
    
    func checkPermission() {
        center.getNotificationSettings { settings in
            if settings.authorizationStatus == .authorized {
                self.notificationPermissionGiven = true
            } else {
                print("USER HAS NOT GIVEN PERMISSION")
                self.notificationPermissionGiven = false
            }
        }
    }
    
    func addReminderFor(item: DaysSinceItem) {
        let content = UNMutableNotificationContent()
        
        content.title = "\(item.name)"
        content.body = "It's been \(item.daysAgo) days since \(item.name)!"
        content.sound = UNNotificationSound.default
        
        // For testing change the time interval for the trigger.
        let timeInterval: Double = 40
        
        // For testing send trigger every 60 seconds.
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)
        
        //        let dateComponents = getDateComponentsFor(item: item)
        //         let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        print("Our ID is \(item.reminderNotificationID)")
        let request = UNNotificationRequest(identifier: item.reminderNotificationID, content: content, trigger: trigger)
        
        center.getNotificationSettings { settings in
            if settings.authorizationStatus == .authorized {
                self.center.add(request)
                print("🔔 Added notification!")
                print("the request is: \(request)")
            } else {
                self.center.requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
                    if success {
                        self.center.add(request)
                        print("🔔 Added notification!")
                        print("the request is: \(request)")

                    } else {
                        print("Didn't authorize notifications")
                    }
                }
            }
        }
    }
    
    
    func getDateComponentsFor(item: DaysSinceItem) -> DateComponents {
        var dateComponents = DateComponents()
        
        if item.reminder == .none {
            // FIX
            return DateComponents()
        }else if item.reminder == .daily {
            dateComponents.hour = 10
            dateComponents.minute = 0
        } else if item.reminder == .weekly {
            dateComponents.weekday = 1
            dateComponents.hour = 10
            dateComponents.second = 0
        } else if item.reminder == .monthly {
            dateComponents.day = 1
            dateComponents.weekday = 1
            dateComponents.hour = 10
            dateComponents.minute = 0
        }
        
        return dateComponents
    }
    
    func deleteReminderFor(item: DaysSinceItem) {
        center.getPendingNotificationRequests { notifications in
            self.center.removePendingNotificationRequests(withIdentifiers: [item.reminderNotificationID])
        }
    }
    
}
