@testable import DaysSince
import Foundation

/// Deterministic test data. Never uses `Date.now` — day-boundary arithmetic near
/// midnight makes `daysAgo` assertions flaky.
enum Fixtures {
    /// 1970-01-12T13:46:40Z — arbitrary but fixed, and nowhere near a day boundary
    /// in the test host's calendar.
    static let referenceDate = Date(timeIntervalSince1970: 1_000_000)
    static let olderDate = Date(timeIntervalSince1970: 900_000)
    static let newerDate = Date(timeIntervalSince1970: 1_100_000)

    /// A calendar and timezone pinned so weekday/day-of-month assertions don't
    /// depend on where the test happens to run.
    static let gmtCalendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "GMT")!
        return calendar
    }()

    static func category(
        id: UUID = UUID(),
        stableID: String = DaysSince.Category.stableIDWork,
        name: String = "Work",
        emoji: String = "lightbulb",
        color: CategoryColor = .work,
        sortOrder: Int = 0,
        lastModified: Date = referenceDate
    ) -> DaysSince.Category {
        DaysSince.Category(
            id: id,
            stableID: stableID,
            name: name,
            emoji: emoji,
            color: color,
            sortOrder: sortOrder,
            lastModified: lastModified
        )
    }

    static func item(
        id: UUID = UUID(),
        name: String = "Event",
        category: DaysSince.Category? = nil,
        dateLastDone: Date = referenceDate,
        remindersEnabled: Bool = false,
        reminder: DSItemReminders = .daily,
        reminderNotificationID: String = UUID().uuidString,
        lastModified: Date = referenceDate
    ) -> DSItem {
        DSItem(
            id: id,
            name: name,
            category: category ?? self.category(),
            dateLastDone: dateLastDone,
            remindersEnabled: remindersEnabled,
            reminder: reminder,
            reminderNotificationID: reminderNotificationID,
            lastModified: lastModified
        )
    }
}
