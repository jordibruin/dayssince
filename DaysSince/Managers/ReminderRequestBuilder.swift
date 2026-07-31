//
//  ReminderRequestBuilder.swift
//  DaysSince
//

import Foundation
import UserNotifications

/// Builds the reminder notification requests for an event. Extracted from
/// `NotificationManager` so the scheduling rules are testable without
/// `UNUserNotificationCenter`.
enum ReminderRequestBuilder {

    /// Reminders fire at 10:00 in the calendar's time zone.
    static let defaultHour = 10
    static let defaultMinute = 0

    static func content(for item: DSItem) -> UNMutableNotificationContent? {
        guard let body = body(for: item.reminder, name: item.name) else { return nil }

        let content = UNMutableNotificationContent()
        content.title = item.name
        content.body = body
        content.sound = .default
        return content
    }

    static func dateComponents(
        for item: DSItem,
        hour: Int = ReminderRequestBuilder.defaultHour,
        minute: Int = ReminderRequestBuilder.defaultMinute,
        calendar: Calendar = .current
    ) -> DateComponents? {
        var components = DateComponents()
        components.calendar = calendar
        components.timeZone = calendar.timeZone
        components.hour = hour
        components.minute = minute

        switch item.reminder {
        case .daily:
            break
        case .weekly:
            components.weekday = calendar.component(.weekday, from: item.dateLastDone)
        case .monthly:
            components.day = calendar.component(.day, from: item.dateLastDone)
        case .none:
            return nil
        }

        return components
    }

    static func requests(for item: DSItem, calendar: Calendar = .current) -> [UNNotificationRequest] {
        guard let content = content(for: item),
              let components = dateComponents(for: item, calendar: calendar)
        else {
            return []
        }

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(
            identifier: item.reminderNotificationID,
            content: content,
            trigger: trigger
        )
        return [request]
    }

    /// The pending identifiers belonging to `item`. Matching is by prefix because an
    /// event's requests were historically suffixed (`<id>0`, `<id>1`); the trade-off is
    /// that an identifier which merely starts with this event's ID also matches.
    static func identifiers(matching item: DSItem, in identifiers: [String]) -> [String] {
        identifiers.filter { $0.hasPrefix(item.reminderNotificationID) }
    }

    private static func body(for reminder: DSItemReminders, name: String) -> String? {
        switch reminder {
        case .daily: "One more day since \(name)!"
        case .weekly: "It's been another week since \(name)!"
        case .monthly: "It's been another month since \(name)!"
        case .none: nil
        }
    }
}
