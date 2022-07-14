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
    
    static func placeholderItem() -> DaysSinceItem {
        return DaysSinceItem(name: "Placeholder", category: CategoryDaysSinceItem.hobbies, dateLastDone: Date.now, remindersEnabled: false)
    }
    
    
}
