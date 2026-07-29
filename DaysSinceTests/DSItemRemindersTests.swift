@testable import DaysSince
import Foundation
import Testing

@Suite("DSItemReminders")
struct DSItemRemindersTests {
    // MARK: - All Cases

    @Test("There are 4 reminder options")
    func allCasesCount() {
        #expect(DSItemReminders.allCases.count == 4)
    }

    @Test("allCases is ordered daily, weekly, monthly, none")
    func allCasesOrder() {
        let expected: [DSItemReminders] = [.daily, .weekly, .monthly, .none]
        #expect(DSItemReminders.allCases == expected)
    }

    // MARK: - Name

    @Test(
        "Each reminder has a display name",
        arguments: [
            (DSItemReminders.daily, "Daily"),
            (DSItemReminders.weekly, "Weekly"),
            (DSItemReminders.monthly, "Monthly"),
            (DSItemReminders.none, "No reminders"),
        ]
    )
    func name(reminder: DSItemReminders, expectedName: String) {
        #expect(reminder.name == expectedName)
    }

    // MARK: - Codable

    @Test("Every reminder survives a JSON round trip", arguments: DSItemReminders.allCases)
    func codableRoundTrip(reminder: DSItemReminders) throws {
        let data = try JSONEncoder().encode(reminder)
        let decoded = try JSONDecoder().decode(DSItemReminders.self, from: data)
        #expect(decoded == reminder)
    }

    // MARK: - Equatable

    @Test("Equatable compares cases")
    func equatable() {
        #expect(DSItemReminders.daily == DSItemReminders.daily)
        #expect(DSItemReminders.daily != DSItemReminders.weekly)
        #expect(DSItemReminders.monthly != DSItemReminders.none)
    }

    // MARK: - Hashable

    @Test("All 4 cases hash distinctly")
    func hashable() {
        var set = Set<DSItemReminders>()
        for reminder in DSItemReminders.allCases {
            set.insert(reminder)
        }
        #expect(set.count == 4)
    }

    // MARK: - Default Value in DSItem

    @Test("A new DSItem defaults to daily reminders")
    func defaultReminderInDSItem() {
        // Memberwise init on purpose: this asserts the default value of `reminder`.
        let item = DSItem(
            id: UUID(),
            name: "Test",
            category: DaysSince.Category.placeholderCategory(),
            dateLastDone: Date.now,
            remindersEnabled: true
        )
        #expect(item.reminder == .daily)
    }
}
