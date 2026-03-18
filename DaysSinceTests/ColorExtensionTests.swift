@testable import DaysSince
import SwiftUI
import XCTest

final class ColorExtensionTests: XCTestCase {
    // MARK: - Named Colors Exist

    func testCustomColorsExist() {
        // These should not crash when accessed
        _ = Color.workColor
        _ = Color.lifeColor
        _ = Color.hobbiesColor
        _ = Color.healthColor
        _ = Color.backgroundColor
        _ = Color.peachLightPink
        _ = Color.peachDarkPink
        _ = Color.marioBlue
        _ = Color.marioRed
        _ = Color.zeldaGreen
        _ = Color.zeldaYellow
        _ = Color.animalCrossingsBrown
        _ = Color.animalCrossingsGreen
    }

    // MARK: - UIColor Mix

    func testMixWithWhite() {
        let red = UIColor.red
        let mixed = red.mix(with: .white, amount: 0.5)

        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        mixed.getRed(&r, green: &g, blue: &b, alpha: &a)

        // Red mixed 50% with white should be roughly (1.0, 0.5, 0.5)
        XCTAssertEqual(r, 1.0, accuracy: 0.01)
        XCTAssertEqual(g, 0.5, accuracy: 0.01)
        XCTAssertEqual(b, 0.5, accuracy: 0.01)
    }

    func testMixWithBlack() {
        let white = UIColor.white
        let mixed = white.mix(with: .black, amount: 0.5)

        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        mixed.getRed(&r, green: &g, blue: &b, alpha: &a)

        // White mixed 50% with black should be roughly (0.5, 0.5, 0.5)
        XCTAssertEqual(r, 0.5, accuracy: 0.01)
        XCTAssertEqual(g, 0.5, accuracy: 0.01)
        XCTAssertEqual(b, 0.5, accuracy: 0.01)
    }

    func testMixZeroAmount() {
        let red = UIColor.red
        let mixed = red.mix(with: .blue, amount: 0)

        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        mixed.getRed(&r, green: &g, blue: &b, alpha: &a)

        XCTAssertEqual(r, 1.0, accuracy: 0.01)
        XCTAssertEqual(g, 0.0, accuracy: 0.01)
        XCTAssertEqual(b, 0.0, accuracy: 0.01)
    }

    func testMixFullAmount() {
        let red = UIColor.red
        let mixed = red.mix(with: .blue, amount: 1.0)

        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        mixed.getRed(&r, green: &g, blue: &b, alpha: &a)

        XCTAssertEqual(r, 0.0, accuracy: 0.01)
        XCTAssertEqual(g, 0.0, accuracy: 0.01)
        XCTAssertEqual(b, 1.0, accuracy: 0.01)
    }

    // MARK: - Lighter / Darker

    func testLighterMakesLighter() {
        let original = UIColor.red
        let lighter = original.lighter(by: 0.3)

        var r1: CGFloat = 0, g1: CGFloat = 0, b1: CGFloat = 0, a1: CGFloat = 0
        var r2: CGFloat = 0, g2: CGFloat = 0, b2: CGFloat = 0, a2: CGFloat = 0

        original.getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
        lighter.getRed(&r2, green: &g2, blue: &b2, alpha: &a2)

        // Lighter should increase green and blue channels (mixing with white)
        XCTAssertGreaterThanOrEqual(g2, g1)
        XCTAssertGreaterThanOrEqual(b2, b1)
    }

    func testDarkerMakesDarker() {
        let original = UIColor.white
        let darker = original.darker(by: 0.3)

        var r1: CGFloat = 0, g1: CGFloat = 0, b1: CGFloat = 0, a1: CGFloat = 0
        var r2: CGFloat = 0, g2: CGFloat = 0, b2: CGFloat = 0, a2: CGFloat = 0

        original.getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
        darker.getRed(&r2, green: &g2, blue: &b2, alpha: &a2)

        // Darker should decrease all channels (mixing with black)
        XCTAssertLessThan(r2, r1)
        XCTAssertLessThan(g2, g1)
        XCTAssertLessThan(b2, b1)
    }

    // MARK: - Color Extension Lighter/Darker

    func testColorLighter() {
        let color = Color.red
        // Should not crash
        _ = color.lighter(by: 0.2)
    }

    func testColorDarker() {
        let color = Color.blue
        // Should not crash
        _ = color.darker(by: 0.2)
    }

    func testColorLighterDefaultAmount() {
        let color = Color.green
        _ = color.lighter()
    }

    func testColorDarkerDefaultAmount() {
        let color = Color.green
        _ = color.darker()
    }
}
