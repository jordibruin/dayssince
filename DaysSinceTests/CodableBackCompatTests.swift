@testable import DaysSince
import Foundation
import Testing

/// Stored data predates several fields. Swift's synthesized `Decodable` does **not**
/// fall back to a property's default value for a missing key, so every late-added
/// field needs `decodeIfPresent`. Each test here removes one key from a real encoded
/// payload — if someone adds a field without `decodeIfPresent`, one of these fails
/// instead of users silently losing their data.
@Suite("Codable back compatibility")
struct CodableBackCompatTests {

    private let decoder = JSONDecoder()

    // MARK: - DSItem

    @Test(
        "an item still decodes with a late-added field missing",
        arguments: ["reminder", "dateCompleted", "reminderNotificationID", "lastModified"]
    )
    func itemDecodesWithoutOptionalField(key: String) throws {
        let item = Fixtures.item(name: "Dentist", remindersEnabled: true, reminder: .weekly)
        let data = try LegacyPayloads.encoded(item, without: [key])

        let decoded = try decoder.decode(DSItem.self, from: data)

        #expect(decoded.id == item.id)
        #expect(decoded.name == "Dentist")
        #expect(decoded.remindersEnabled)
    }

    @Test("a missing reminder defaults to daily")
    func missingReminderDefaultsToDaily() throws {
        let data = try LegacyPayloads.encoded(Fixtures.item(reminder: .monthly), without: ["reminder"])

        #expect(try decoder.decode(DSItem.self, from: data).reminder == .daily)
    }

    @Test("a missing reminderNotificationID is regenerated")
    func missingNotificationIDIsRegenerated() throws {
        let data = try LegacyPayloads.encoded(Fixtures.item(), without: ["reminderNotificationID"])

        let decoded = try decoder.decode(DSItem.self, from: data)

        #expect(UUID(uuidString: decoded.reminderNotificationID) != nil)
    }

    @Test("an item with every late-added field missing still decodes")
    func itemDecodesWithAllOptionalFieldsMissing() throws {
        let item = Fixtures.item(name: "Ancient")
        let data = try LegacyPayloads.encoded(
            item,
            without: ["reminder", "dateCompleted", "reminderNotificationID", "lastModified"]
        )

        let decoded = try decoder.decode(DSItem.self, from: data)

        #expect(decoded.name == "Ancient")
        #expect(decoded.reminder == .daily)
    }

    @Test(
        "an item without a required field fails to decode",
        arguments: ["id", "name", "category", "dateLastDone", "remindersEnabled"]
    )
    func itemFailsWithoutRequiredField(key: String) throws {
        let data = try LegacyPayloads.encoded(Fixtures.item(), without: [key])

        #expect(throws: (any Error).self) {
            try JSONDecoder().decode(DSItem.self, from: data)
        }
    }

    // MARK: - Category

    @Test(
        "a category still decodes with a late-added field missing",
        arguments: ["stableID", "sortOrder", "lastModified"]
    )
    func categoryDecodesWithoutOptionalField(key: String) throws {
        let category = Fixtures.category(name: "Work", sortOrder: 3)
        let data = try LegacyPayloads.encoded(category, without: [key])

        let decoded = try decoder.decode(DaysSince.Category.self, from: data)

        #expect(decoded.name == "Work")
        #expect(decoded.emoji == category.emoji)
        #expect(decoded.color == category.color)
    }

    @Test("a missing sortOrder defaults to zero")
    func missingSortOrderDefaultsToZero() throws {
        let data = try LegacyPayloads.encoded(Fixtures.category(sortOrder: 7), without: ["sortOrder"])

        #expect(try decoder.decode(DaysSince.Category.self, from: data).sortOrder == 0)
    }

    @Test(
        "every built-in category name maps to its hardcoded stableID",
        arguments: [
            ("Work", DaysSince.Category.stableIDWork),
            ("Life", DaysSince.Category.stableIDLife),
            ("Hobby", DaysSince.Category.stableIDHobby),
            ("Health", DaysSince.Category.stableIDHealth),
            ("Home", DaysSince.Category.stableIDHome),
            ("Pet", DaysSince.Category.stableIDPet),
            ("Friends", DaysSince.Category.stableIDFriends),
            ("Projects", DaysSince.Category.stableIDProjects),
            ("Journal", DaysSince.Category.stableIDJournal),
        ]
    )
    func builtInNamesMapToStableIDs(name: String, expected: String) throws {
        let data = try LegacyPayloads.category(named: name)

        #expect(try decoder.decode(DaysSince.Category.self, from: data).stableID == expected)
    }

    @Test("an unknown category name gets a generated UUID stableID")
    func unknownNameGetsUUIDStableID() throws {
        let data = try LegacyPayloads.category(named: "Gardening")

        let stableID = try decoder.decode(DaysSince.Category.self, from: data).stableID

        #expect(UUID(uuidString: stableID) != nil)
    }

    @Test("the built-in name mapping is case sensitive")
    func nameMappingIsCaseSensitive() throws {
        let data = try LegacyPayloads.category(named: "work")

        #expect(try decoder.decode(DaysSince.Category.self, from: data).stableID != DaysSince.Category.stableIDWork)
    }

    @Test("an item whose nested category predates stableID still decodes")
    func nestedLegacyCategoryDecodes() throws {
        let item = Fixtures.item(category: Fixtures.category(stableID: "removed", name: "Life"))
        let data = try LegacyPayloads.encodedItem(item, withoutCategoryKeys: ["stableID"])

        let decoded = try decoder.decode(DSItem.self, from: data)

        #expect(decoded.category.stableID == DaysSince.Category.stableIDLife)
    }

    // MARK: - Stored enum shape

    /// `CategoryColor` and `DSItemReminders` are `Codable` enums with no raw value, so
    /// Swift encodes them as `{"<case>":{}}`. Giving either a raw value or an associated
    /// value would change that shape and orphan every stored event.
    @Test("raw-value-less enums encode as a single-key object")
    func enumWireFormat() throws {
        let item = Fixtures.item(category: Fixtures.category(color: .marioBlue), reminder: .weekly)
        let json = try JSONSerialization.jsonObject(with: JSONEncoder().encode(item)) as! [String: Any]

        let reminder = try #require(json["reminder"] as? [String: Any])
        let category = try #require(json["category"] as? [String: Any])
        let color = try #require(category["color"] as? [String: Any])

        #expect(Array(reminder.keys) == ["weekly"])
        #expect(reminder["weekly"] as? [String: Any] != nil)
        #expect(Array(color.keys) == ["marioBlue"])
    }

    @Test("every color case round trips", arguments: CategoryColor.allCases)
    func colorRoundTrips(color: CategoryColor) throws {
        let data = try JSONEncoder().encode(Fixtures.category(color: color))

        #expect(try decoder.decode(DaysSince.Category.self, from: data).color == color)
    }

    @Test("every reminder case round trips", arguments: DSItemReminders.allCases)
    func reminderRoundTrips(reminder: DSItemReminders) throws {
        let data = try JSONEncoder().encode(Fixtures.item(reminder: reminder))

        #expect(try decoder.decode(DSItem.self, from: data).reminder == reminder)
    }

    // MARK: - Identity

    @Test("categories sharing a stableID collapse in a Set")
    func sameStableIDCollapsesInSet() {
        let a = Fixtures.category(id: UUID(), stableID: "pets", name: "Pets")
        let b = Fixtures.category(id: UUID(), stableID: "pets", name: "Pets renamed", emoji: "star", color: .black)

        #expect(Set([a, b]).count == 1)
        #expect(a.hashValue == b.hashValue)
    }

    @Test("categories with different stableIDs stay distinct in a Set")
    func differentStableIDsStayDistinct() {
        let shared = UUID()
        let a = Fixtures.category(id: shared, stableID: "a", name: "Same")
        let b = Fixtures.category(id: shared, stableID: "b", name: "Same")

        #expect(Set([a, b]).count == 2)
    }
}
