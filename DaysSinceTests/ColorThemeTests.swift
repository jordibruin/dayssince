@testable import DaysSince
import SwiftUI
import Testing

@Suite("ColorTheme identity")
struct ColorThemeTests {
    @Test("Creation stores id and colors")
    func creation() {
        let theme = ColorTheme(id: "test", mainColor: .red, backgroundColor: .blue)
        #expect(theme.id == "test")
        #expect(theme.mainColor == .red)
        #expect(theme.backgroundColor == .blue)
    }

    @Test("Themes with the same id are equal regardless of colors")
    func equalityBasedOnId() {
        let theme1 = ColorTheme(id: "a", mainColor: .red, backgroundColor: .blue)
        let theme2 = ColorTheme(id: "a", mainColor: .green, backgroundColor: .yellow)
        // Identity is the id, not the colors
        #expect(theme1 == theme2)
    }

    @Test("Themes with different ids are not equal")
    func inequalityDifferentId() {
        let theme1 = ColorTheme(id: "a", mainColor: .red, backgroundColor: .blue)
        let theme2 = ColorTheme(id: "b", mainColor: .red, backgroundColor: .blue)
        #expect(theme1 != theme2)
    }

    @Test("Hashing agrees with equality")
    func hashMatchesEquality() {
        let theme1 = ColorTheme(id: "a", mainColor: .red, backgroundColor: .blue)
        let theme2 = ColorTheme(id: "a", mainColor: .green, backgroundColor: .yellow)
        let theme3 = ColorTheme(id: "b", mainColor: .red, backgroundColor: .blue)

        // Equal values must hash equally, or Set/ForEach identity breaks
        #expect(theme1.hashValue == theme2.hashValue)

        var set = Set<ColorTheme>()
        set.insert(theme1)
        set.insert(theme2)
        set.insert(theme3)

        #expect(set.count == 2)
    }

    @Test("Shipped themes are uniquely identified")
    func shippedThemesHaveUniqueIdentity() {
        let themes = ThemeView().colorThemes
        #expect(
            Set(themes).count == themes.count,
            "Themes must be uniquely identified — ForEach(colorThemes) traps on duplicates"
        )
        #expect(Set(themes.map(\.id)).count == themes.count)
    }
}
