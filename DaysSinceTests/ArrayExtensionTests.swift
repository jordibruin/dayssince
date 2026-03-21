@testable import DaysSince

import XCTest

final class ArrayExtensionTests: XCTestCase {
    // MARK: - String Array

    func testStringArrayRoundTrip() {
        let original = ["hello", "world", "test"]
        let rawValue = original.rawValue
        let decoded = [String](rawValue: rawValue)
        XCTAssertEqual(decoded, original)
    }

    // MARK: - Int Array

    func testIntArrayRoundTrip() {
        let original = [1, 2, 3, 4, 5]
        let rawValue = original.rawValue
        let decoded = [Int](rawValue: rawValue)
        XCTAssertEqual(decoded, original)
    }

    // MARK: - Empty Array

    func testEmptyArrayRoundTrip() {
        let original: [String] = []
        let rawValue = original.rawValue
        let decoded = [String](rawValue: rawValue)
        XCTAssertEqual(decoded, original)
    }

    // MARK: - DSItem Array

    func testDSItemArrayRoundTrip() {
        let category = DaysSince.Category(name: "Work", emoji: "lightbulb", color: .work)
        let items = [
            DSItem(id: UUID(), name: "Event 1", category: category, dateLastDone: Date.now, remindersEnabled: true),
            DSItem(id: UUID(), name: "Event 2", category: category, dateLastDone: Date.now, remindersEnabled: false),
        ]

        let rawValue = items.rawValue
        let decoded = [DSItem](rawValue: rawValue)

        XCTAssertNotNil(decoded)
        XCTAssertEqual(decoded?.count, 2)
        XCTAssertEqual(decoded?[0].name, "Event 1")
        XCTAssertEqual(decoded?[1].name, "Event 2")
    }

    // MARK: - Invalid Data

    func testInvalidRawValueReturnsNil() {
        let decoded = [String](rawValue: "not valid json")
        XCTAssertNil(decoded)
    }

    func testEmptyStringReturnsNil() {
        let decoded = [String](rawValue: "")
        XCTAssertNil(decoded)
    }

    // MARK: - Raw Value Format

    func testRawValueIsValidJSON() {
        let array = ["a", "b", "c"]
        let rawValue = array.rawValue
        let data = rawValue.data(using: .utf8)!
        let json = try? JSONSerialization.jsonObject(with: data)
        XCTAssertNotNil(json)
    }

    // MARK: - Category Array

    func testCategoryArrayRoundTrip() {
        let categories = [
            DaysSince.Category(name: "Work", emoji: "lightbulb", color: .work),
            DaysSince.Category(name: "Life", emoji: "leaf", color: .life),
        ]

        let rawValue = categories.rawValue
        let decoded = [DaysSince.Category](rawValue: rawValue)

        XCTAssertNotNil(decoded)
        XCTAssertEqual(decoded?.count, 2)
        XCTAssertEqual(decoded?[0].name, "Work")
        XCTAssertEqual(decoded?[1].name, "Life")
    }
}
