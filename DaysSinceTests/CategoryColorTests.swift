@testable import DaysSince
import Foundation
import SwiftUI
import Testing

@Suite("CategoryColor")
struct CategoryColorTests {
    // MARK: - All Cases

    @Test("There are 10 category colors")
    func allCasesCount() {
        #expect(CategoryColor.allCases.count == 10)
    }

    @Test("allCases lists every color in display order")
    func allCasesContainsExpectedValues() {
        let expected: [CategoryColor] = [
            .work, .life, .hobbies, .health, .marioBlue, .zeldaYellow,
            .animalCrossingsGreen, .marioRed, .animalCrossingsBrown, .black,
        ]
        #expect(CategoryColor.allCases == expected)
    }

    // MARK: - ID

    @Test(
        "Each color exposes its stable id string",
        arguments: [
            (CategoryColor.work, "Work"),
            (CategoryColor.life, "Life"),
            (CategoryColor.health, "Health"),
            (CategoryColor.hobbies, "Hobby"),
            (CategoryColor.marioBlue, "MarioBlue"),
            (CategoryColor.zeldaYellow, "ZeldaYellow"),
            (CategoryColor.animalCrossingsGreen, "AnimalCrossingsGreen"),
            (CategoryColor.marioRed, "MarioRed"),
            (CategoryColor.animalCrossingsBrown, "AnimalCrossingsBrown"),
            (CategoryColor.black, "Black"),
        ]
    )
    func idValue(color: CategoryColor, expectedID: String) {
        #expect(color.id == expectedID)
    }

    // MARK: - Color

    @Test("Resolving the color of every case does not crash", arguments: CategoryColor.allCases)
    func colorPropertyResolves(colorCase: CategoryColor) {
        // Asset-backed colors: the point is that lookup succeeds for every case.
        _ = colorCase.color
    }

    @Test("Black maps to Color.black")
    func blackColorIsBlack() {
        #expect(CategoryColor.black.color == Color.black)
    }

    // MARK: - Foreground Color

    @Test(
        "Black inverts for legibility per color scheme",
        arguments: zip([ColorScheme.dark, ColorScheme.light], [Color.white, Color.black])
    )
    func foregroundColorForBlack(scheme: ColorScheme, expected: Color) {
        #expect(CategoryColor.black.foregroundColor(for: scheme) == expected)
    }

    @Test(
        "Non-black colors keep their own color in either scheme",
        arguments: [
            (CategoryColor.work, ColorScheme.dark),
            (CategoryColor.life, ColorScheme.light),
        ]
    )
    func foregroundColorForNonBlack(color: CategoryColor, scheme: ColorScheme) {
        #expect(color.foregroundColor(for: scheme) == color.color)
    }

    // MARK: - Codable

    @Test("Every color survives a JSON round trip", arguments: CategoryColor.allCases)
    func codableRoundTrip(colorCase: CategoryColor) throws {
        let data = try JSONEncoder().encode(colorCase)
        let decoded = try JSONDecoder().decode(CategoryColor.self, from: data)
        #expect(decoded == colorCase)
    }

    // MARK: - Equatable

    @Test("Equatable compares cases")
    func equatable() {
        #expect(CategoryColor.work == CategoryColor.work)
        #expect(CategoryColor.work != CategoryColor.life)
    }

    // MARK: - Hashable

    @Test("All 10 cases hash distinctly")
    func hashable() {
        var set = Set<CategoryColor>()
        for colorCase in CategoryColor.allCases {
            set.insert(colorCase)
        }
        #expect(set.count == 10)
    }
}
