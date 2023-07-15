//
//  NotificationManager.swift
//  DaysSince
//
//  Created by Jordi Bruin on 01/07/2022.
//

import Foundation
import UserNotifications
import SwiftUI


class NotificationManager: ObservableObject {
    
    let center = UNUserNotificationCenter.current()
    
    @Published var pendingNotifications: [UNNotificationRequest] = []
    
    @AppStorage("items", store: UserDefaults(suiteName: "group.goodsnooze.dayssince")) var items: [DSItem] = []
    
    init() {
        // refresh notifications
        refreshNotifications()
    }
    
    func refreshNotifications() {
        print("refresh notifications")
        // Remove all old pending requests to generate new ones
        center.removeAllPendingNotificationRequests()
        
        // iterate over all items
        for item in items {
            if item.remindersEnabled {
                addReminderFor(item: item)
            }
        }
        
        getPendingNotification()
    }
    
    
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
    
    func addReminderFor(item: DSItem) {
        
//        var notificationsContent: [UNMutableNotificationContent]
        
        var requests: [UNNotificationRequest] = []
        
        switch item.reminder {
        case .daily:
            for i in 0...6 {
                let content = UNMutableNotificationContent()
                content.title = "\(item.name)"
                content.body = "It's been \(item.daysAgo + i) days since \(item.name)!"
                content.sound = UNNotificationSound.default
                
                let dateComponents = getDateComponentsFor(item: item, extraDays: Double(i))
                let trigger = UNCalendarNotificationTrigger(
                    dateMatching: dateComponents,
                    repeats: false
                )
                
                let request = UNNotificationRequest(
                    identifier: "\(item.reminderNotificationID)\(i)",
                    content: content,
                    trigger: trigger
                )
                requests.append(request)
            }
        case .weekly:
            for i in 0...3 {
                let content = UNMutableNotificationContent()
                content.title = "\(item.name)"
                content.body = "It's been \(item.daysAgo + (i * 7)) days since \(item.name)!"
                content.sound = UNNotificationSound.default
                
                let dateComponents = getDateComponentsFor(item: item, extraDays: (Double(i) * 7))
                let trigger = UNCalendarNotificationTrigger(
                    dateMatching: dateComponents,
                    repeats: false
                )
                
                let request = UNNotificationRequest(
                    identifier: "\(item.reminderNotificationID)\(i)",
                    content: content,
                    trigger: trigger
                )
                requests.append(request)
            }
        case .monthly:
            for i in 0...3 {
                let content = UNMutableNotificationContent()
                content.title = "\(item.name)"
                content.body = "It's been \(item.daysAgo + (i * 30)) days since \(item.name)!"
                content.sound = UNNotificationSound.default
                
                let dateComponents = getDateComponentsFor(item: item, extraDays: (Double(i) * 30))
                let trigger = UNCalendarNotificationTrigger(
                    dateMatching: dateComponents,
                    repeats: false
                )
                
                let request = UNNotificationRequest(
                    identifier: "\(item.reminderNotificationID)\(i)",
                    content: content,
                    trigger: trigger
                )
                requests.append(request)
            }
        default:
            return
        }
        
        

        
        // For testing change the time interval for the trigger.
//        let timeInterval: Double = 60
        
        // For testing send trigger every 60 seconds.
//        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: true)
        
//        let dateComponents = getDateComponentsFor(item: item, extraDays: <#T##Int#>)
//        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
//
//        print("Our ID is \(item.reminderNotificationID)")
//        let request = UNNotificationRequest(
//            identifier: item.reminderNotificationID,
//            content: content,
//            trigger: trigger
//        )
//
        center.getNotificationSettings { settings in
            if settings.authorizationStatus == .authorized {
                for request in requests {
                    self.center.add(request)
                    print("🔔 Added notification!")
                    print("the request is: \(request)")
                }
            } else {
                self.center.requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
                    if success {
                        for request in requests {
                            self.center.add(request)
                            print("🔔 Added notification!")
                            print("the request is: \(request)")
                        }

                    } else {
                        print("Didn't authorize notifications")
                    }
                }
            }
            self.getPendingNotification()
        }
    }
    
    
    func getDateComponentsFor(item: DSItem, extraDays: Double) -> DateComponents {
        var dateComponents = DateComponents()
        
        if item.reminder == .none {
            // FIX
            return DateComponents()
        }else if item.reminder == .daily {
            dateComponents.day = Calendar.current.dateComponents([.day], from: item.dateLastDone.addingTimeInterval(extraDays * 86400)).day
            dateComponents.hour = 10
            dateComponents.minute = 0
        } else if item.reminder == .weekly {
            dateComponents.weekday = Calendar.current.dateComponents([.day], from: item.dateLastDone.addingTimeInterval(extraDays * 86400)).weekday
            dateComponents.hour = 10
            dateComponents.second = 0
        } else if item.reminder == .monthly {
            dateComponents.day = Calendar.current.dateComponents([.day], from: item.dateLastDone.addingTimeInterval(extraDays * 86400)).day
            
            dateComponents.weekday = Calendar.current.dateComponents([.day], from: item.dateLastDone.addingTimeInterval(extraDays * 86400)).weekday
            
            dateComponents.hour = 10
            dateComponents.minute = 0
        }
        
        return dateComponents
    }
    
    func deleteReminderFor(item: DSItem) {
        center.getPendingNotificationRequests { notifications in
            self.center.removePendingNotificationRequests(withIdentifiers: [item.reminderNotificationID])
        }
    }
    
}
