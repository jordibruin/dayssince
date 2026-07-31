@testable import DaysSince
import SwiftUI
import Testing
import UIKit

@Suite("Color and UIColor extensions")
struct ColorExtensionTests {
    /// Replaces the repeated `var r/g/b/a` + `getRed` boilerplate.
    private func rgb(_ color: UIColor) -> (r: CGFloat, g: CGFloat, b: CGFloat) {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        color.getRed(&r, green: &g, blue: &b, alpha: &a)
        return (r, g, b)
    }

    // MARK: - Named Colors Exist

    @Test("custom named colors resolve without crashing")
    func customColorsExist() {
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

    @Test("red mixed 50% with white")
    func mixWithWhite() {
        let mixed = rgb(UIColor.red.mix(with: .white, amount: 0.5))

        // Red mixed 50% with white should be roughly (1.0, 0.5, 0.5)
        #expect(abs(mixed.r - 1.0) < 0.01)
        #expect(abs(mixed.g - 0.5) < 0.01)
        #expect(abs(mixed.b - 0.5) < 0.01)
    }

    @Test("white mixed 50% with black")
    func mixWithBlack() {
        let mixed = rgb(UIColor.white.mix(with: .black, amount: 0.5))

        // White mixed 50% with black should be roughly (0.5, 0.5, 0.5)
        #expect(abs(mixed.r - 0.5) < 0.01)
        #expect(abs(mixed.g - 0.5) < 0.01)
        #expect(abs(mixed.b - 0.5) < 0.01)
    }

    @Test("mix amount 0 keeps the base color")
    func mixZeroAmount() {
        let mixed = rgb(UIColor.red.mix(with: .blue, amount: 0))

        #expect(abs(mixed.r - 1.0) < 0.01)
        #expect(abs(mixed.g - 0.0) < 0.01)
        #expect(abs(mixed.b - 0.0) < 0.01)
    }

    @Test("mix amount 1 becomes the other color")
    func mixFullAmount() {
        let mixed = rgb(UIColor.red.mix(with: .blue, amount: 1.0))

        #expect(abs(mixed.r - 0.0) < 0.01)
        #expect(abs(mixed.g - 0.0) < 0.01)
        #expect(abs(mixed.b - 1.0) < 0.01)
    }

    // MARK: - Lighter / Darker

    @Test("lighter raises channels toward white")
    func lighterMakesLighter() {
        let original = rgb(UIColor.red)
        let lighter = rgb(UIColor.red.lighter(by: 0.3))

        // Lighter should increase green and blue channels (mixing with white)
        #expect(lighter.g >= original.g)
        #expect(lighter.b >= original.b)
    }

    @Test("darker lowers all channels toward black")
    func darkerMakesDarker() {
        let original = rgb(UIColor.white)
        let darker = rgb(UIColor.white.darker(by: 0.3))

        // Darker should decrease all channels (mixing with black)
        #expect(darker.r < original.r)
        #expect(darker.g < original.g)
        #expect(darker.b < original.b)
    }

    // MARK: - Color Extension Lighter/Darker

    @Test("Color.lighter(by:) does not crash")
    func colorLighter() {
        let color = Color.red
        // Should not crash
        _ = color.lighter(by: 0.2)
    }

    @Test("Color.darker(by:) does not crash")
    func colorDarker() {
        let color = Color.blue
        // Should not crash
        _ = color.darker(by: 0.2)
    }

    @Test("Color.lighter() default amount does not crash")
    func colorLighterDefaultAmount() {
        let color = Color.green
        _ = color.lighter()
    }

    @Test("Color.darker() default amount does not crash")
    func colorDarkerDefaultAmount() {
        let color = Color.green
        _ = color.darker()
    }
}
