@testable import DaysSince
import XCTest


final class DSItemTests: XCTestCase {
    // MARK: - Creation

    func testPlaceholderItem() {
        let item = DSItem.placeholderItem()
        XCTAssertEqual(item.name, "Placeholder")
        XCTAssertFalse(item.remindersEnabled)
        XCTAssertEqual(item.category.name, "Placeholder")
    }

    func testItemCreationWithDefaults() {
        let category = DaysSince.Category(name: "Work", emoji: "lightbulb", color: .work)
        let item = DSItem(
            id: UUID(),
            name: "Test Event",
            category: category,
            dateLastDone: Date.now,
            remindersEnabled: true
        )

        XCTAssertEqual(item.name, "Test Event")
        XCTAssertEqual(item.category, category)
        XCTAssertTrue(item.remindersEnabled)
        XCTAssertEqual(item.reminder, .daily)
    }

    // MARK: - Emoji

    func testEmojiComesFromCategory() {
        let category = DaysSince.Category(name: "Health", emoji: "heart", color: .health)
        let item = DSItem(
            id: UUID(),
            name: "Gym",
            category: category,
            dateLastDone: Date.now,
            remindersEnabled: false
        )
        XCTAssertEqual(item.emoji, "heart")
    }

    // MARK: - Days Ago

    func testDaysAgoForToday() {
        let item = DSItem(
            id: UUID(),
            name: "Today",
            category: DaysSince.Category.placeholderCategory(),
            dateLastDone: Date.now,
            remindersEnabled: false
        )
        XCTAssertEqual(item.daysAgo, 0)
    }

    func testDaysAgoForPastDate() {
        let threeDaysAgo = Calendar.current.date(byAdding: .day, value: -3, to: Date.now)!
        let item = DSItem(
            id: UUID(),
            name: "Past",
            category: DaysSince.Category.placeholderCategory(),
            dateLastDone: threeDaysAgo,
            remindersEnabled: false
        )
        XCTAssertEqual(item.daysAgo, 3)
    }

    func testDaysAgoForYesterday() {
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date.now)!
        let item = DSItem(
            id: UUID(),
            name: "Yesterday",
            category: DaysSince.Category.placeholderCategory(),
            dateLastDone: yesterday,
            remindersEnabled: false
        )
        XCTAssertEqual(item.daysAgo, 1)
    }

    func testDaysAgoForDistantPast() {
        let longAgo = Calendar.current.date(byAdding: .day, value: -365, to: Date.now)!
        let item = DSItem(
            id: UUID(),
            name: "Long Ago",
            category: DaysSince.Category.placeholderCategory(),
            dateLastDone: longAgo,
            remindersEnabled: false
        )
        XCTAssertEqual(item.daysAgo, 365)
    }

    // MARK: - Completed Days Ago

    func testCompletedDaysAgoForToday() {
        var item = DSItem(
            id: UUID(),
            name: "Completed",
            category: DaysSince.Category.placeholderCategory(),
            dateLastDone: Date.now,
            remindersEnabled: false
        )
        item.dateCompleted = Date.now
        XCTAssertEqual(item.completedDaysAgo, 0)
    }

    // MARK: - Codable

    func testCodableRoundTrip() throws {
        let category = DaysSince.Category(name: "Life", emoji: "leaf", color: .life)
        let original = DSItem(
            id: UUID(),
            name: "Codable Test",
            category: category,
            dateLastDone: Date.now,
            remindersEnabled: true,
            reminder: .weekly
        )

        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(DSItem.self, from: data)

        XCTAssertEqual(decoded.id, original.id)
        XCTAssertEqual(decoded.name, original.name)
        XCTAssertEqual(decoded.category, original.category)
        XCTAssertEqual(decoded.remindersEnabled, original.remindersEnabled)
        XCTAssertEqual(decoded.reminder, original.reminder)
    }

    // MARK: - Identifiable

    func testIdentifiable() {
        let item = DSItem.placeholderItem()
        XCTAssertNotNil(item.id)
    }

    func testUniqueIDs() {
        let item1 = DSItem.placeholderItem()
        let item2 = DSItem.placeholderItem()
        XCTAssertNotEqual(item1.id, item2.id)
    }

    // MARK: - Reminder Notification ID

    func testReminderNotificationIDIsUnique() {
        let item1 = DSItem.placeholderItem()
        let item2 = DSItem.placeholderItem()
        XCTAssertNotEqual(item1.reminderNotificationID, item2.reminderNotificationID)
    }
}
