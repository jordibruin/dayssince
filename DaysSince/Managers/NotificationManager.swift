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
 getPendingNotification
 checkPermission: Checks whether the user has given permission to receive notification
 addReminderFor: Create notifications for an event
 deleteReminderFor: Deletes existing notifications for an event

 The request-building rules live in `ReminderRequestBuilder`.
 */
class NotificationManager: ObservableObject {

    private let scheduler: NotificationScheduling

    @Published var pendingNotifications: [UNNotificationRequest] = []
    @Published var notificationPermissionGiven = true

    /// Items are provided externally via `refreshNotifications(items:)`. On init we still do
    /// an initial refresh from App Group UserDefaults for backward compatibility.
    init(
        scheduler: NotificationScheduling = UserNotificationCenterScheduler(),
        appGroupDefaults: UserDefaults? = UserDefaults(suiteName: "group.goodsnooze.dayssince"),
        autoRefresh: Bool = true
    ) {
        self.scheduler = scheduler

        guard autoRefresh, let appGroupDefaults else { return }
        refreshNotifications(items: DataSyncManager.loadItems(from: appGroupDefaults))
    }

    /// Refresh the notifications. Delete all and reschedule them. Used when app is started and when a user edits an event to make sure the notifications stay up to date.
    func refreshNotifications(items: [DSItem]) {
        scheduler.removeAllPending()

        for item in items where item.remindersEnabled {
            addReminderFor(item: item)
        }

        getPendingNotification()
    }

    /// Get the notifications that are scheduled and pending (not sent yet)
    func getPendingNotification() {
        scheduler.pendingRequests { requests in
            DispatchQueue.main.async {
                self.pendingNotifications = requests
            }
        }
    }

    /// Check if user has given permission to the app to send notifications
    func checkPermission() {
        scheduler.authorizationStatus { status in
            DispatchQueue.main.async {
                self.notificationPermissionGiven = status == .authorized
            }
        }
    }

    /// Add reminders for a days since event
    /// - Parameter item: Days Since event to schedule reminders for
    func addReminderFor(item: DSItem) {
        let requests = ReminderRequestBuilder.requests(for: item)
        guard !requests.isEmpty else { return }

        scheduler.authorizationStatus { status in
            if status == .authorized {
                self.scheduler.removePending(identifiers: [item.reminderNotificationID])
                requests.forEach(self.scheduler.add)
            } else {
                self.scheduler.requestAuthorization { granted in
                    guard granted else { return }
                    requests.forEach(self.scheduler.add)
                }
            }

            self.getPendingNotification()
        }
    }

    /// Delete the reminder notifications for a Days Since item.
    /// - Parameter item: event to delete the reminders for
    func deleteReminderFor(item: DSItem) {
        scheduler.pendingRequests { requests in
            let matching = ReminderRequestBuilder.identifiers(matching: item, in: requests.map(\.identifier))
            self.scheduler.removePending(identifiers: matching)
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
