@testable import DaysSince
import XCTest


final class CategoryTests: XCTestCase {
    // MARK: - Creation

    func testCategoryCreation() {
        let category = DaysSince.Category(name: "Work", emoji: "lightbulb", color: .work)
        XCTAssertEqual(category.name, "Work")
        XCTAssertEqual(category.emoji, "lightbulb")
        XCTAssertEqual(category.color, .work)
    }

    func testCategoryCreationWithCustomID() {
        let id = UUID()
        let category = DaysSince.Category(id: id, name: "Test", emoji: "star", color: .life)
        XCTAssertEqual(category.id, id)
    }

    func testPlaceholderCategory() {
        let placeholder = DaysSince.Category.placeholderCategory()
        XCTAssertEqual(placeholder.name, "Placeholder")
        XCTAssertEqual(placeholder.emoji, "placeholder")
        XCTAssertEqual(placeholder.color, .work)
    }

    // MARK: - Equality

    func testEqualityBasedOnID() {
        let id = UUID()
        let cat1 = DaysSince.Category(id: id, name: "Work", emoji: "lightbulb", color: .work)
        let cat2 = DaysSince.Category(id: id, name: "Different Name", emoji: "star", color: .life)
        XCTAssertEqual(cat1, cat2, "Categories with the same ID should be equal")
    }

    func testInequalityWithDifferentIDs() {
        let cat1 = DaysSince.Category(name: "Work", emoji: "lightbulb", color: .work)
        let cat2 = DaysSince.Category(name: "Work", emoji: "lightbulb", color: .work)
        XCTAssertNotEqual(cat1, cat2, "Categories with different IDs should not be equal")
    }

    // MARK: - Hashable Identifier

    func testHashableIdentifier() {
        let id = UUID()
        let category = DaysSince.Category(id: id, name: "Work", emoji: "lightbulb", color: .work)
        let expected = "\(id)-Work-lightbulb-\(CategoryColor.work)"
        XCTAssertEqual(category.hashableIdentifier, expected)
    }

    func testHashableIdentifierChangesWithProperties() {
        let id = UUID()
        var category = DaysSince.Category(id: id, name: "Work", emoji: "lightbulb", color: .work)
        let hash1 = category.hashableIdentifier

        category.name = "Life"
        let hash2 = category.hashableIdentifier

        XCTAssertNotEqual(hash1, hash2)
    }

    // MARK: - Codable

    func testCodableRoundTrip() throws {
        let original = DaysSince.Category(name: "Health", emoji: "heart.text.square", color: .health)
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(DaysSince.Category.self, from: data)

        XCTAssertEqual(decoded.id, original.id)
        XCTAssertEqual(decoded.name, original.name)
        XCTAssertEqual(decoded.emoji, original.emoji)
        XCTAssertEqual(decoded.color, original.color)
    }

    func testCodableArrayRoundTrip() throws {
        let categories = [
            DaysSince.Category(name: "Work", emoji: "lightbulb", color: .work),
            DaysSince.Category(name: "Life", emoji: "leaf", color: .life),
            DaysSince.Category(name: "Health", emoji: "heart.text.square", color: .health),
        ]

        let data = try JSONEncoder().encode(categories)
        let decoded = try JSONDecoder().decode([DaysSince.Category].self, from: data)

        XCTAssertEqual(decoded.count, 3)
        XCTAssertEqual(decoded[0].name, "Work")
        XCTAssertEqual(decoded[1].name, "Life")
        XCTAssertEqual(decoded[2].name, "Health")
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
