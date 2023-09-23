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
 * refreshNotifications
 * getPendingNotifications
 * checkPermission: Checks whether the user has given permission to receive notification
 * addReminderFor
 * addReminderFor: Create notifications for an event
 * deleteReminderFor: Deletes existing notifications for an event
 * getDateComponentsFor:

 */
class NotificationManager: ObservableObject {
    let center = UNUserNotificationCenter.current()

    @Published var pendingNotifications: [UNNotificationRequest] = []

    @AppStorage("items", store: UserDefaults(suiteName: "group.goodsnooze.dayssince")) var items: [DSItem] = []

    init() {
        // Refresh notifications
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

    func addReminderFor(item: DSItem) {
//        var notificationsContent: [UNMutableNotificationContent]

        var requests: [UNNotificationRequest] = []

        switch item.reminder {
        case .daily:
            for i in 0 ... 6 {
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
            for i in 0 ... 3 {
                let content = UNMutableNotificationContent()
                content.title = "\(item.name)"
                content.body = "It's been \(item.daysAgo + (i * 7)) days since \(item.name)!"
                content.sound = UNNotificationSound.default

                let dateComponents = getDateComponentsFor(item: item, extraDays: Double(i) * 7)
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
            for i in 0 ... 3 {
                let content = UNMutableNotificationContent()
                content.title = "\(item.name)"
                content.body = "It's been \(item.daysAgo + (i * 30)) days since \(item.name)!"
                content.sound = UNNotificationSound.default

                let dateComponents = getDateComponentsFor(item: item, extraDays: Double(i) * 30)
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
            if matchingIdentifiers != nil {
                self.center.removePendingNotificationRequests(withIdentifiers: matchingIdentifiers)
            }
        }
    }
}
