@testable import DaysSince
import XCTest


final class CategoryTests: XCTestCase {
    // MARK: - Creation

    func testCategoryCreation() {
        let category = DaysSince.Category(name: "Work", emoji: "lightbulb", color: .work)
        XCTAssertEqual(category.name, "Work")
        XCTAssertEqual(category.emoji, "lightbulb")
        XCTAssertEqual(category.color, .work)
        XCTAssertFalse(category.stableID.isEmpty)
    }

    func testCategoryCreationWithCustomID() {
        let id = UUID()
        let category = DaysSince.Category(id: id, stableID: "custom", name: "Test", emoji: "star", color: .life)
        XCTAssertEqual(category.id, id)
        XCTAssertEqual(category.stableID, "custom")
    }

    func testPlaceholderCategory() {
        let placeholder = DaysSince.Category.placeholderCategory()
        XCTAssertEqual(placeholder.name, "Placeholder")
        XCTAssertEqual(placeholder.emoji, "placeholder")
        XCTAssertEqual(placeholder.color, .work)
        XCTAssertEqual(placeholder.stableID, "placeholder")
    }

    // MARK: - Equality (based on stableID)

    func testEqualityBasedOnStableID() {
        let cat1 = DaysSince.Category(stableID: "work", name: "Work", emoji: "lightbulb", color: .work)
        let cat2 = DaysSince.Category(stableID: "work", name: "Different Name", emoji: "star", color: .life)
        XCTAssertEqual(cat1, cat2, "Categories with the same stableID should be equal")
    }

    func testInequalityWithDifferentStableIDs() {
        let cat1 = DaysSince.Category(name: "Work", emoji: "lightbulb", color: .work)
        let cat2 = DaysSince.Category(name: "Work", emoji: "lightbulb", color: .work)
        XCTAssertNotEqual(cat1, cat2, "Categories with different stableIDs should not be equal")
    }

    func testEqualityIgnoresUUID() {
        let cat1 = DaysSince.Category(id: UUID(), stableID: "same", name: "A", emoji: "a", color: .work)
        let cat2 = DaysSince.Category(id: UUID(), stableID: "same", name: "B", emoji: "b", color: .life)
        XCTAssertEqual(cat1, cat2, "UUID should not affect equality — only stableID matters")
    }

    // MARK: - Hashable Identifier

    func testHashableIdentifier() {
        let category = DaysSince.Category(stableID: "work", name: "Work", emoji: "lightbulb", color: .work)
        let expected = "work-Work-lightbulb-\(CategoryColor.work)"
        XCTAssertEqual(category.hashableIdentifier, expected)
    }

    func testHashableIdentifierChangesWithProperties() {
        var category = DaysSince.Category(stableID: "test", name: "Work", emoji: "lightbulb", color: .work)
        let hash1 = category.hashableIdentifier

        category.name = "Life"
        let hash2 = category.hashableIdentifier

        XCTAssertNotEqual(hash1, hash2)
    }

    // MARK: - Codable

    func testCodableRoundTrip() throws {
        let original = DaysSince.Category(stableID: "health", name: "Health", emoji: "heart.text.square", color: .health)
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(DaysSince.Category.self, from: data)

        XCTAssertEqual(decoded.id, original.id)
        XCTAssertEqual(decoded.stableID, original.stableID)
        XCTAssertEqual(decoded.name, original.name)
        XCTAssertEqual(decoded.emoji, original.emoji)
        XCTAssertEqual(decoded.color, original.color)
    }

    func testCodableArrayRoundTrip() throws {
        let categories = [
            DaysSince.Category(stableID: "work", name: "Work", emoji: "lightbulb", color: .work),
            DaysSince.Category(stableID: "life", name: "Life", emoji: "leaf", color: .life),
            DaysSince.Category(stableID: "health", name: "Health", emoji: "heart.text.square", color: .health),
        ]

        let data = try JSONEncoder().encode(categories)
        let decoded = try JSONDecoder().decode([DaysSince.Category].self, from: data)

        XCTAssertEqual(decoded.count, 3)
        XCTAssertEqual(decoded[0].stableID, "work")
        XCTAssertEqual(decoded[1].stableID, "life")
        XCTAssertEqual(decoded[2].stableID, "health")
    }

    // MARK: - Migration (decoding without stableID)

    func testDecodingWithoutStableIDUsesBuiltInMapping() throws {
        // Simulate stored data from before stableID was added
        let json = """
        {"id":"550e8400-e29b-41d4-a716-446655440000","name":"Work","emoji":"lightbulb","color":{"work":{}}}
        """
        let data = json.data(using: .utf8)!
        let decoded = try JSONDecoder().decode(DaysSince.Category.self, from: data)

        XCTAssertEqual(decoded.stableID, "work", "Built-in category should get well-known stableID from name")
        XCTAssertEqual(decoded.name, "Work")
    }

    func testDecodingWithoutStableIDGeneratesUUIDForUnknown() throws {
        // Simulate a user-created category stored before stableID existed
        let json = """
        {"id":"550e8400-e29b-41d4-a716-446655440000","name":"My Custom","emoji":"star","color":{"life":{}}}
        """
        let data = json.data(using: .utf8)!
        let decoded = try JSONDecoder().decode(DaysSince.Category.self, from: data)

        XCTAssertFalse(decoded.stableID.isEmpty, "Unknown category should get a generated stableID")
        XCTAssertNotEqual(decoded.stableID, "work")
        XCTAssertNotEqual(decoded.stableID, "life")
    }

    // MARK: - Mutability

    func testMutableProperties() {
        var category = DaysSince.Category(name: "Work", emoji: "lightbulb", color: .work)
        category.name = "Updated"
        category.emoji = "star"
        category.color = .health

        XCTAssertEqual(category.name, "Updated")
        XCTAssertEqual(category.emoji, "star")
        XCTAssertEqual(category.color, .health)
    }
}
