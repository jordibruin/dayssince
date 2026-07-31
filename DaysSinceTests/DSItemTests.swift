@testable import DaysSince
import Foundation
import Testing

@Suite("DSItem model")
struct DSItemTests {
    // MARK: - Creation

    @Test("Placeholder item has placeholder name, category and no reminders")
    func placeholderItem() {
        let item = DSItem.placeholderItem()
        #expect(item.name == "Placeholder")
        #expect(!item.remindersEnabled)
        #expect(item.category.name == "Placeholder")
    }

    @Test("Item creation stores values and defaults reminder to daily")
    func itemCreationWithDefaults() {
        // Uses the memberwise init directly: this test exercises the default
        // value of `reminder`, so it must not go through a fixture helper.
        let category = DaysSince.Category(name: "Work", emoji: "lightbulb", color: .work)
        let item = DSItem(
            id: UUID(),
            name: "Test Event",
            category: category,
            dateLastDone: Date.now,
            remindersEnabled: true
        )

        #expect(item.name == "Test Event")
        #expect(item.category == category)
        #expect(item.remindersEnabled)
        #expect(item.reminder == .daily)
    }

    // MARK: - Emoji

    @Test("Emoji comes from the item's category")
    func emojiComesFromCategory() {
        let item = Fixtures.item(
            name: "Gym",
            category: Fixtures.category(
                stableID: DaysSince.Category.stableIDHealth,
                name: "Health",
                emoji: "heart",
                color: .health
            )
        )
        #expect(item.emoji == "heart")
    }

    // MARK: - Days Ago

    // Deliberately relative to `Date.now`, matching the original tests: `daysAgo`
    // is defined against the current date, so pinning a fixed date would not
    // exercise the same behavior.
    @Test("daysAgo counts whole days since dateLastDone", arguments: [0, 1, 3, 365])
    func daysAgo(dayOffset: Int) {
        let date = Calendar.current.date(byAdding: .day, value: -dayOffset, to: Date.now)!
        let item = DSItem(
            id: UUID(),
            name: "Event",
            category: DaysSince.Category.placeholderCategory(),
            dateLastDone: date,
            remindersEnabled: false
        )
        #expect(item.daysAgo == dayOffset)
    }

    // MARK: - Completed Days Ago

    @Test("completedDaysAgo is zero when completed today")
    func completedDaysAgoForToday() {
        var item = DSItem(
            id: UUID(),
            name: "Completed",
            category: DaysSince.Category.placeholderCategory(),
            dateLastDone: Date.now,
            remindersEnabled: false
        )
        item.dateCompleted = Date.now
        #expect(item.completedDaysAgo == 0)
    }

    // MARK: - Codable

    @Test("Item survives a JSON encode/decode round trip")
    func codableRoundTrip() throws {
        let original = Fixtures.item(
            name: "Codable Test",
            category: Fixtures.category(
                stableID: DaysSince.Category.stableIDLife,
                name: "Life",
                emoji: "leaf",
                color: .life
            ),
            remindersEnabled: true,
            reminder: .weekly
        )

        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(DSItem.self, from: data)

        #expect(decoded.id == original.id)
        #expect(decoded.name == original.name)
        #expect(decoded.category == original.category)
        #expect(decoded.remindersEnabled == original.remindersEnabled)
        #expect(decoded.reminder == original.reminder)
    }

    // MARK: - Identifiable

    @Test("Item exposes a valid UUID identity")
    func identifiable() {
        let item = DSItem.placeholderItem()
        #expect(UUID(uuidString: item.id.uuidString) != nil)
    }

    @Test("Each item gets a unique id")
    func uniqueIDs() {
        let item1 = DSItem.placeholderItem()
        let item2 = DSItem.placeholderItem()
        #expect(item1.id != item2.id)
    }

    // MARK: - Reminder Notification ID

    @Test("Each item gets a unique reminder notification id")
    func reminderNotificationIDIsUnique() {
        let item1 = DSItem.placeholderItem()
        let item2 = DSItem.placeholderItem()
        #expect(item1.reminderNotificationID != item2.reminderNotificationID)
    }
}
