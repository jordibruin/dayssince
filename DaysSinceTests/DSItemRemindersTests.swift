@testable import DaysSince

import XCTest

final class DSItemRemindersTests: XCTestCase {
    // MARK: - All Cases

    func testAllCasesCount() {
        XCTAssertEqual(DSItemReminders.allCases.count, 4)
    }

    func testAllCasesOrder() {
        let expected: [DSItemReminders] = [.daily, .weekly, .monthly, .none]
        XCTAssertEqual(DSItemReminders.allCases, expected)
    }

    // MARK: - Name

    func testDailyName() {
        XCTAssertEqual(DSItemReminders.daily.name, "Daily")
    }

    func testWeeklyName() {
        XCTAssertEqual(DSItemReminders.weekly.name, "Weekly")
    }

    func testMonthlyName() {
        XCTAssertEqual(DSItemReminders.monthly.name, "Monthly")
    }

    func testNoneName() {
        XCTAssertEqual(DSItemReminders.none.name, "No reminders")
    }

    // MARK: - Codable

    func testCodableRoundTrip() throws {
        for reminder in DSItemReminders.allCases {
            let data = try JSONEncoder().encode(reminder)
            let decoded = try JSONDecoder().decode(DSItemReminders.self, from: data)
            XCTAssertEqual(decoded, reminder)
        }
    }

    // MARK: - Equatable

    func testEquatable() {
        XCTAssertEqual(DSItemReminders.daily, DSItemReminders.daily)
        XCTAssertNotEqual(DSItemReminders.daily, DSItemReminders.weekly)
        XCTAssertNotEqual(DSItemReminders.monthly, DSItemReminders.none)
    }

    // MARK: - Hashable

    func testHashable() {
        var set = Set<DSItemReminders>()
        for reminder in DSItemReminders.allCases {
            set.insert(reminder)
        }
        XCTAssertEqual(set.count, 4)
    }

    // MARK: - Default Value in DSItem

    func testDefaultReminderInDSItem() {
        let item = DSItem(
            id: UUID(),
            name: "Test",
            category: DaysSince.Category.placeholderCategory(),
            dateLastDone: Date.now,
            remindersEnabled: true
        )
        XCTAssertEqual(item.reminder, .daily)
    }
}
