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

    /// Timestamp of last modification, used for future conflict resolution.
    var lastModified: Date = .now

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

// Custom decoder in an extension to preserve the memberwise init.
// Auto-synthesized Decodable does NOT fall back to default values for missing keys,
// so we must use decodeIfPresent for fields added after initial release.
extension DSItem {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        category = try container.decode(Category.self, forKey: .category)
        dateLastDone = try container.decode(Date.self, forKey: .dateLastDone)
        remindersEnabled = try container.decode(Bool.self, forKey: .remindersEnabled)
        reminder = try container.decodeIfPresent(DSItemReminders.self, forKey: .reminder) ?? .daily
        dateCompleted = try container.decodeIfPresent(Date.self, forKey: .dateCompleted) ?? .now
        reminderNotificationID = try container.decodeIfPresent(String.self, forKey: .reminderNotificationID) ?? UUID().uuidString
        lastModified = try container.decodeIfPresent(Date.self, forKey: .lastModified) ?? .now
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
