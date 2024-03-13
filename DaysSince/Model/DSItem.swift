//
//  DSItem.swift
//  DaysSince
//
//  Created by Vicki Minerva on 3/30/22.
//

import Foundation
import SwiftUI
import UserNotifications

/// Element used to store an event / item in Days Since.
struct DSItem: Identifiable, Codable {
    let id: UUID

    /// The name of the item.
    var name: String

    /// Category of the item.
    var category: Category

    /// Day last done.
    var dateLastDone: Date

    // Whether the item sends reminders.
    var remindersEnabled: Bool

    // What type of reminder (daily, weekly, monthly)
    var reminder: DSItemReminders = .daily

    // We're no longer using this.
    // Date when item was completed (it was over).
    var dateCompleted: Date = .now

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

    static func placeholderItem() -> DSItem {
        let category = Category.placeholderCategory()
        return DSItem(id: UUID(), name: "Placeholder", category: category, dateLastDone: Date.now, remindersEnabled: false)
    }
}

struct oldDSItem: Identifiable, Codable {
    let id: UUID

    /// The name of the item.
    var name: String

    /// Category of the item.
    var category = CategoryDSIte.work

    /// Day last done.
    var dateLastDone: Date

    // Whether the item sends reminders.
    var remindersEnabled: Bool

    // What type of reminder (daily, weekly, monthly)
    var reminder: DSItemReminders = .daily

    // We're no longer using this.
    // Date when item was completed (it was over).
    var dateCompleted: Date = .now

    /// The emoji of the item.
    var emoji: String {
        return category.sfSymbolName
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
}
