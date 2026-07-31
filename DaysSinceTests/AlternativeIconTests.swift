@testable import DaysSince
import Foundation
import Testing

@Suite("AlternativeIcon")
struct AlternativeIconTests {
    @Test("ID is the name concatenated with the icon name")
    func idComputation() {
        let icon = AlternativeIcon(name: "Purple", iconName: "calendar-purple", premium: false, original: false)
        #expect(icon.id == "Purplecalendar-purple")
    }

    @Test("Different icons have different ids")
    func idIsUnique() {
        let icon1 = AlternativeIcon(name: "Purple", iconName: "calendar-purple", premium: false, original: false)
        let icon2 = AlternativeIcon(name: "Blue", iconName: "calendar-blue", premium: false, original: false)
        #expect(icon1.id != icon2.id)
    }

    @Test("Premium flag is stored as given", arguments: [true, false])
    func premiumProperty(premium: Bool) {
        let icon = AlternativeIcon(
            name: premium ? "Premium" : "Free",
            iconName: premium ? "premium-icon" : "free-icon",
            premium: premium,
            original: false
        )
        #expect(icon.premium == premium)
    }

    @Test("Original flag is stored as given", arguments: [true, false])
    func originalProperty(original: Bool) {
        let icon = AlternativeIcon(
            name: original ? "Default" : "Alt",
            iconName: original ? "AppIcon" : "alt-icon",
            premium: false,
            original: original
        )
        #expect(icon.original == original)
    }

    @Test("Name and icon name are stored as given")
    func properties() {
        let icon = AlternativeIcon(name: "TestName", iconName: "test-icon", premium: true, original: false)
        #expect(icon.name == "TestName")
        #expect(icon.iconName == "test-icon")
    }
}
