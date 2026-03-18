@testable import DaysSince
import XCTest

final class AlternativeIconTests: XCTestCase {
    func testIDComputation() {
        let icon = AlternativeIcon(name: "Purple", iconName: "calendar-purple", premium: false, original: false)
        XCTAssertEqual(icon.id, "Purplecalendar-purple")
    }

    func testIDIsUnique() {
        let icon1 = AlternativeIcon(name: "Purple", iconName: "calendar-purple", premium: false, original: false)
        let icon2 = AlternativeIcon(name: "Blue", iconName: "calendar-blue", premium: false, original: false)
        XCTAssertNotEqual(icon1.id, icon2.id)
    }

    func testPremiumProperty() {
        let premiumIcon = AlternativeIcon(name: "Premium", iconName: "premium-icon", premium: true, original: false)
        let freeIcon = AlternativeIcon(name: "Free", iconName: "free-icon", premium: false, original: false)
        XCTAssertTrue(premiumIcon.premium)
        XCTAssertFalse(freeIcon.premium)
    }

    func testOriginalProperty() {
        let originalIcon = AlternativeIcon(name: "Default", iconName: "AppIcon", premium: false, original: true)
        let altIcon = AlternativeIcon(name: "Alt", iconName: "alt-icon", premium: false, original: false)
        XCTAssertTrue(originalIcon.original)
        XCTAssertFalse(altIcon.original)
    }

    func testProperties() {
        let icon = AlternativeIcon(name: "TestName", iconName: "test-icon", premium: true, original: false)
        XCTAssertEqual(icon.name, "TestName")
        XCTAssertEqual(icon.iconName, "test-icon")
    }
}
