//
//  NotificationManager.swift
//  DaysSince
//
//  Created by Jordi Bruin on 01/07/2022.
//

import Foundation
import SwiftUI
import UserNotifications

/**
 This class is responsible for managing the notifications for the reminders of different events.
 Methods:
 refreshNotifications
 getPendingNotifications
 checkPermission: Checks whether the user has given permission to receive notification
 addReminderFor
 addReminderFor: Create notifications for an event
 deleteReminderFor: Deletes existing notifications for an event
 getDateComponentsFor:

 */
class NotificationManager: ObservableObject {
    let center = UNUserNotificationCenter.current()

    @Published var pendingNotifications: [UNNotificationRequest] = []

    @AppStorage("items", store: UserDefaults(suiteName: "group.goodsnooze.dayssince")) var items: [DSItem] = []

    init() {
        // Refresh notifications
        refreshNotifications()
    }

    /// Refresh the notifications. Delete all and reschedule them. Used when app is started and when a user edits an event to make sure the notifications stay up to date.
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

    /// Get the notifications that are scheduled and pending (not sent yet)
    func getPendingNotification() {
        center.getPendingNotificationRequests { requests in

            DispatchQueue.main.async {
                // if there are none we stop
                guard !requests.isEmpty else {
                    print("No notification requests")
                    self.pendingNotifications = []
                    return
                }

                self.pendingNotifications = requests
                print("Notification requests open")
            }

            // Used for observability purposes when testing.
            for request in requests {
                print("Request.identifier", request.identifier)
                print("Request.content.title", request.content.title)
                print("Request.content.body", request.content.body)
            }
        }
    }

    @Published var notificationPermissionGiven = true

    /// Check if user has given permission to the app to send notifications
    private func checkPermission() {
        center.getNotificationSettings { settings in
            if settings.authorizationStatus == .authorized {
                self.notificationPermissionGiven = true
            } else {
                print("USER HAS NOT GIVEN PERMISSION")
                self.notificationPermissionGiven = false
            }
        }
    }

    /// Add reminders for a days since event
    /// - Parameter item: Days Since event to schedule reminders for
    func addReminderFor(item: DSItem) {

        var requests: [UNNotificationRequest] = []
        
        // Time for the notifications is hardcoded at 10am
        let hour = 10
        let minute = 0

        switch item.reminder {
            
        case .daily:
            let content = UNMutableNotificationContent()
            content.title = "\(item.name)"
            content.body = "One more day since \(item.name)!"
            content.sound = UNNotificationSound.default

            let calendar = Calendar.current
            var dateComponents = DateComponents(calendar: calendar, timeZone: TimeZone.current)
            dateComponents.hour = hour
            dateComponents.minute = minute
            
            let trigger = UNCalendarNotificationTrigger(
                dateMatching: dateComponents,
                repeats: true
            )

            let request = UNNotificationRequest(
                identifier: "\(item.reminderNotificationID)",
                content: content,
                trigger: trigger
            )
            requests.append(request)

        case .weekly:
            let content = UNMutableNotificationContent()
            content.title = "\(item.name)"
            content.body = "It's been another week since \(item.name)!"
            content.sound = UNNotificationSound.default

            var dateComponents = DateComponents()
            dateComponents.calendar = Calendar.current
            let weekday = Calendar.current.component(.weekday, from: item.dateLastDone)
            dateComponents.weekday = weekday
            dateComponents.hour = hour
            dateComponents.minute = minute
            
            let trigger = UNCalendarNotificationTrigger(
                dateMatching: dateComponents,
                repeats: true
            )

            let request = UNNotificationRequest(
                identifier: "\(item.reminderNotificationID)",
                content: content,
                trigger: trigger
            )
            requests.append(request)
            
        case .monthly:
            let content = UNMutableNotificationContent()
            content.title = "\(item.name)"
            content.body = "It's been another month since \(item.name)!"
            content.sound = UNNotificationSound.default

            var dateComponents = DateComponents()
            dateComponents.calendar = Calendar.current
            let dayOfMonth = Calendar.current.component(.day, from: item.dateLastDone)
            dateComponents.day = dayOfMonth
            dateComponents.hour = hour
            dateComponents.minute = minute
            
            let trigger = UNCalendarNotificationTrigger(
                dateMatching: dateComponents,
                repeats: true
            )

            let request = UNNotificationRequest(
                identifier: "\(item.reminderNotificationID)",
                content: content,
                trigger: trigger
            )
            requests.append(request)
        
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
                    
                    self.center.removePendingNotificationRequests(withIdentifiers: ["\(item.reminderNotificationID)"])
                    self.center.add(request)
                    
                    print("🗑️ Removed pending notification requests with indetifiers \([item.reminderNotificationID])")
                    print("🔔 Added notification!")
                    print("The request is: \(request)")
                }
            } else {
                self.center.requestAuthorization(options: [.alert, .badge, .sound]) { success, _ in
                    if success {
                        for request in requests {
                            self.center.add(request)
                            print("🔔 Added notification!")
                            print("The request is: \(request)")
                        }

                    } else {
                        print("Didn't authorize notifications")
                    }
                }
            }
            self.getPendingNotification()
        }
    }

    /// Create the date for a reminder notification of a Days Since Item
    /// - Parameters:
    ///   - item: Days Since event to get the date components for
    ///   - extraDays: The extra days  -- 7 for a week, 30 for a month, etc.
    /// - Returns: Date components for the dates of a reminder
    private func getDateComponentsFor(item: DSItem, extraDays: Double) -> DateComponents {
        var dateComponents = DateComponents()
        let startDate = Calendar.current.startOfDay(for: Date())

        if item.reminder == .none {
            // FIX
            return DateComponents()
        } else if item.reminder == .daily {
            dateComponents.day = Calendar.current.dateComponents([.day], from: startDate.addingTimeInterval(extraDays * 86400)).day
            dateComponents.hour = 10
            dateComponents.minute = 0
        } else if item.reminder == .weekly {
            dateComponents.weekday = Calendar.current.dateComponents([.day], from: startDate.addingTimeInterval(extraDays * 86400)).weekday
            dateComponents.hour = 10
            dateComponents.second = 0
        } else if item.reminder == .monthly {
            dateComponents.day = Calendar.current.dateComponents([.day], from: startDate.addingTimeInterval(extraDays * 86400)).day

            dateComponents.weekday = Calendar.current.dateComponents([.day], from: startDate.addingTimeInterval(extraDays * 86400)).weekday

            dateComponents.hour = 10
            dateComponents.minute = 0
        }

        return dateComponents
    }

    /// Delete the reminder notifications for a Days Since item.
    /// - Parameter item: event to delete the reminders for
    func deleteReminderFor(item: DSItem) {
        /*
          The notification IDs have the following format: reminderNotificationIDX, where X is an integer starting from 0.
          That is why we find the mathcing IDs that begind with reminderNotificationID and delete them.
         */
        center.getPendingNotificationRequests { notifications in
            let matchingIdentifiers = notifications.compactMap { request in
                if request.identifier.starts(with: item.reminderNotificationID) {
                    return request.identifier
                }
                return nil
            }
            
            print("Deleting \(matchingIdentifiers.count) reminders for this event")
            self.center.removePendingNotificationRequests(withIdentifiers: matchingIdentifiers)
            
        }
    }
}

extension NotificationManager {
    static var previewInstance: NotificationManager {
        let manager = NotificationManager()
        // configure as needed
        return manager
    }
}
