@testable import DaysSince
import SwiftUI
import XCTest

final class CategoryColorTests: XCTestCase {
    // MARK: - All Cases

    func testAllCasesCount() {
        XCTAssertEqual(CategoryColor.allCases.count, 10)
    }

    func testAllCasesContainsExpectedValues() {
        let expected: [CategoryColor] = [
            .work, .life, .hobbies, .health, .marioBlue, .zeldaYellow,
            .animalCrossingsGreen, .marioRed, .animalCrossingsBrown, .black,
        ]
        XCTAssertEqual(CategoryColor.allCases, expected)
    }

    // MARK: - ID

    func testIDValues() {
        XCTAssertEqual(CategoryColor.work.id, "Work")
        XCTAssertEqual(CategoryColor.life.id, "Life")
        XCTAssertEqual(CategoryColor.health.id, "Health")
        XCTAssertEqual(CategoryColor.hobbies.id, "Hobby")
        XCTAssertEqual(CategoryColor.marioBlue.id, "MarioBlue")
        XCTAssertEqual(CategoryColor.zeldaYellow.id, "ZeldaYellow")
        XCTAssertEqual(CategoryColor.animalCrossingsGreen.id, "AnimalCrossingsGreen")
        XCTAssertEqual(CategoryColor.marioRed.id, "MarioRed")
        XCTAssertEqual(CategoryColor.animalCrossingsBrown.id, "AnimalCrossingsBrown")
        XCTAssertEqual(CategoryColor.black.id, "Black")
    }

    // MARK: - Color

    func testColorPropertyReturnsNonNilForAllCases() {
        for colorCase in CategoryColor.allCases {
            // Just ensure accessing the color doesn't crash
            _ = colorCase.color
        }
    }

    func testBlackColorIsBlack() {
        XCTAssertEqual(CategoryColor.black.color, Color.black)
    }

    // MARK: - Foreground Color

    func testForegroundColorBlackInDarkMode() {
        let color = CategoryColor.black.foregroundColor(for: .dark)
        XCTAssertEqual(color, Color.white)
    }

    func testForegroundColorBlackInLightMode() {
        let color = CategoryColor.black.foregroundColor(for: .light)
        XCTAssertEqual(color, Color.black)
    }

    func testForegroundColorNonBlackInDarkMode() {
        let color = CategoryColor.work.foregroundColor(for: .dark)
        XCTAssertEqual(color, CategoryColor.work.color)
    }

    func testForegroundColorNonBlackInLightMode() {
        let color = CategoryColor.life.foregroundColor(for: .light)
        XCTAssertEqual(color, CategoryColor.life.color)
    }

    // MARK: - Codable

    func testCodableRoundTrip() throws {
        for colorCase in CategoryColor.allCases {
            let data = try JSONEncoder().encode(colorCase)
            let decoded = try JSONDecoder().decode(CategoryColor.self, from: data)
            XCTAssertEqual(decoded, colorCase)
        }
    }

    // MARK: - Equatable

    func testEquatable() {
        XCTAssertEqual(CategoryColor.work, CategoryColor.work)
        XCTAssertNotEqual(CategoryColor.work, CategoryColor.life)
    }

    // MARK: - Hashable

    func testHashable() {
        var set = Set<CategoryColor>()
        for colorCase in CategoryColor.allCases {
            set.insert(colorCase)
        }
        XCTAssertEqual(set.count, 10)
    }
}
