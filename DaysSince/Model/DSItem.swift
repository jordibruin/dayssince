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

// Widget intent resolution. This lives in DSItem.swift because the file already has app +
// widget target membership; a separate file would have to be wired into both targets (and
// into the test target) by hand.
extension DSItem {

    /// The event a widget intent slot points at, or nil when the slot is unset or the
    /// event has since been deleted.
    static func first(matching id: String?, in items: [DSItem]) -> DSItem? {
        guard let id, !id.isEmpty else { return nil }
        return items.first { $0.id.uuidString == id }
    }

    /// Resolves the slots of a multi-event widget: slot order is preserved, unset and
    /// deleted events are skipped, and no more than `limit` events are returned.
    static func matching(ids: [String?], in items: [DSItem], limit: Int = 5) -> [DSItem] {
        ids
            .compactMap { first(matching: $0, in: items) }
            .prefix(limit)
            .map { $0 }
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
