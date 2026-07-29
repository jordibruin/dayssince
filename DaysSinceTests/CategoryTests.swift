@testable import DaysSince
import Foundation
import Testing

@Suite("Category model")
struct CategoryTests {
    // MARK: - Creation

    @Test("Creation stores name, emoji, color and generates a stableID")
    func categoryCreation() {
        let category = DaysSince.Category(name: "Work", emoji: "lightbulb", color: .work)
        #expect(category.name == "Work")
        #expect(category.emoji == "lightbulb")
        #expect(category.color == .work)
        #expect(!category.stableID.isEmpty)
    }

    @Test("Creation honors an explicit id and stableID")
    func categoryCreationWithCustomID() {
        let id = UUID()
        let category = DaysSince.Category(id: id, stableID: "custom", name: "Test", emoji: "star", color: .life)
        #expect(category.id == id)
        #expect(category.stableID == "custom")
    }

    @Test("Placeholder category has known values")
    func placeholderCategory() {
        let placeholder = DaysSince.Category.placeholderCategory()
        #expect(placeholder.name == "Placeholder")
        #expect(placeholder.emoji == "placeholder")
        #expect(placeholder.color == .work)
        #expect(placeholder.stableID == "placeholder")
    }

    // MARK: - Equality (based on stableID)

    @Test("Categories with the same stableID are equal")
    func equalityBasedOnStableID() {
        let cat1 = DaysSince.Category(stableID: "work", name: "Work", emoji: "lightbulb", color: .work)
        let cat2 = DaysSince.Category(stableID: "work", name: "Different Name", emoji: "star", color: .life)
        #expect(cat1 == cat2, "Categories with the same stableID should be equal")
    }

    @Test("Categories with different stableIDs are not equal")
    func inequalityWithDifferentStableIDs() {
        let cat1 = DaysSince.Category(name: "Work", emoji: "lightbulb", color: .work)
        let cat2 = DaysSince.Category(name: "Work", emoji: "lightbulb", color: .work)
        #expect(cat1 != cat2, "Categories with different stableIDs should not be equal")
    }

    @Test("Equality ignores the UUID")
    func equalityIgnoresUUID() {
        let cat1 = DaysSince.Category(id: UUID(), stableID: "same", name: "A", emoji: "a", color: .work)
        let cat2 = DaysSince.Category(id: UUID(), stableID: "same", name: "B", emoji: "b", color: .life)
        #expect(cat1 == cat2, "UUID should not affect equality — only stableID matters")
    }

    // MARK: - Hashable Identifier

    @Test("hashableIdentifier combines stableID, name, emoji and color")
    func hashableIdentifier() {
        let category = DaysSince.Category(stableID: "work", name: "Work", emoji: "lightbulb", color: .work)
        let expected = "work-Work-lightbulb-\(CategoryColor.work)"
        #expect(category.hashableIdentifier == expected)
    }

    @Test("hashableIdentifier changes when a property changes")
    func hashableIdentifierChangesWithProperties() {
        var category = DaysSince.Category(stableID: "test", name: "Work", emoji: "lightbulb", color: .work)
        let hash1 = category.hashableIdentifier

        category.name = "Life"
        let hash2 = category.hashableIdentifier

        #expect(hash1 != hash2)
    }

    // MARK: - Codable

    @Test("Category survives a JSON encode/decode round trip")
    func codableRoundTrip() throws {
        let original = DaysSince.Category(stableID: "health", name: "Health", emoji: "heart.text.square", color: .health)
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(DaysSince.Category.self, from: data)

        #expect(decoded.id == original.id)
        #expect(decoded.stableID == original.stableID)
        #expect(decoded.name == original.name)
        #expect(decoded.emoji == original.emoji)
        #expect(decoded.color == original.color)
    }

    @Test("Array of categories round trips in order")
    func codableArrayRoundTrip() throws {
        let categories = [
            DaysSince.Category(stableID: "work", name: "Work", emoji: "lightbulb", color: .work),
            DaysSince.Category(stableID: "life", name: "Life", emoji: "leaf", color: .life),
            DaysSince.Category(stableID: "health", name: "Health", emoji: "heart.text.square", color: .health),
        ]

        let data = try JSONEncoder().encode(categories)
        let decoded = try JSONDecoder().decode([DaysSince.Category].self, from: data)

        #expect(decoded.count == 3)
        #expect(decoded[0].stableID == "work")
        #expect(decoded[1].stableID == "life")
        #expect(decoded[2].stableID == "health")
    }

    // MARK: - Migration (decoding without stableID)

    /// Simulates stored data from before `stableID` was added: every built-in
    /// category name must map to its well-known stableID.
    @Test(
        "Decoding legacy data maps built-in names to well-known stableIDs",
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
    func decodingWithoutStableIDUsesBuiltInMapping(name: String, expectedStableID: String) throws {
        let json = """
        {"id":"550e8400-e29b-41d4-a716-446655440000","name":"\(name)","emoji":"lightbulb","color":{"work":{}}}
        """
        let data = json.data(using: .utf8)!
        let decoded = try JSONDecoder().decode(DaysSince.Category.self, from: data)

        #expect(decoded.stableID == expectedStableID, "Built-in category should get well-known stableID from name")
        #expect(decoded.name == name)
    }

    @Test("Decoding legacy data generates a stableID for unknown categories")
    func decodingWithoutStableIDGeneratesUUIDForUnknown() throws {
        // Simulate a user-created category stored before stableID existed
        let json = """
        {"id":"550e8400-e29b-41d4-a716-446655440000","name":"My Custom","emoji":"star","color":{"life":{}}}
        """
        let data = json.data(using: .utf8)!
        let decoded = try JSONDecoder().decode(DaysSince.Category.self, from: data)

        #expect(!decoded.stableID.isEmpty, "Unknown category should get a generated stableID")
        #expect(decoded.stableID != "work")
        #expect(decoded.stableID != "life")
    }

    // MARK: - Mutability

    @Test("Name, emoji and color are mutable")
    func mutableProperties() {
        var category = DaysSince.Category(name: "Work", emoji: "lightbulb", color: .work)
        category.name = "Updated"
        category.emoji = "star"
        category.color = .health

        #expect(category.name == "Updated")
        #expect(category.emoji == "star")
        #expect(category.color == .health)
    }
}
