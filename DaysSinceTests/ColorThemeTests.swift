@testable import DaysSince
import SwiftUI
import XCTest

final class ColorThemeTests: XCTestCase {
    func testCreation() {
        let theme = ColorTheme(id: "test", mainColor: .red, backgroundColor: .blue)
        XCTAssertEqual(theme.id, "test")
        XCTAssertEqual(theme.mainColor, .red)
        XCTAssertEqual(theme.backgroundColor, .blue)
    }

    func testEqualityBasedOnColors() {
        let theme1 = ColorTheme(id: "a", mainColor: .red, backgroundColor: .blue)
        let theme2 = ColorTheme(id: "b", mainColor: .red, backgroundColor: .blue)
        // Equality is based on colors, not id
        XCTAssertEqual(theme1, theme2)
    }

    func testInequalityDifferentMainColor() {
        let theme1 = ColorTheme(id: "a", mainColor: .red, backgroundColor: .blue)
        let theme2 = ColorTheme(id: "a", mainColor: .green, backgroundColor: .blue)
        XCTAssertNotEqual(theme1, theme2)
    }

    func testInequalityDifferentBackgroundColor() {
        let theme1 = ColorTheme(id: "a", mainColor: .red, backgroundColor: .blue)
        let theme2 = ColorTheme(id: "a", mainColor: .red, backgroundColor: .green)
        XCTAssertNotEqual(theme1, theme2)
    }

    func testHashable() {
        let theme1 = ColorTheme(id: "a", mainColor: .red, backgroundColor: .blue)
        let theme2 = ColorTheme(id: "b", mainColor: .red, backgroundColor: .blue)
        let theme3 = ColorTheme(id: "c", mainColor: .green, backgroundColor: .blue)

        var set = Set<ColorTheme>()
        set.insert(theme1)
        set.insert(theme2) // same colors as theme1
        set.insert(theme3)

        XCTAssertEqual(set.count, 2)
    }
}
