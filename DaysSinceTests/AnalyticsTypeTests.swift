@testable import DaysSince
import XCTest

final class AnalyticsTypeTests: XCTestCase {
    // MARK: - Raw Values

    func testRawValues() {
        XCTAssertEqual(AnalyticType.launchApp.rawValue, "launchApp")
        XCTAssertEqual(AnalyticType.addNewEvent.rawValue, "addNewEvent")
        XCTAssertEqual(AnalyticType.editEvent.rawValue, "editEvent")
        XCTAssertEqual(AnalyticType.updateCategory.rawValue, "updateCategory")
        XCTAssertEqual(AnalyticType.addNewCategory.rawValue, "addNewCategory")
        XCTAssertEqual(AnalyticType.chooseIcon.rawValue, "chooseIcon")
        XCTAssertEqual(AnalyticType.chooseTheme.rawValue, "chooseTheme")
        XCTAssertEqual(AnalyticType.settingsReview.rawValue, "settingsReview")
        XCTAssertEqual(AnalyticType.reviewPrompt.rawValue, "reviewPrompt")
        XCTAssertEqual(AnalyticType.detailedModeOn.rawValue, "detailedModeOn")
    }

    // MARK: - String Value Consistency

    func testStringValueMatchesRawValue() {
        let allCases: [AnalyticType] = [
            .launchApp, .addNewEvent, .editEvent,
            .updateCategory, .addNewCategory,
            .chooseIcon, .chooseTheme,
            .settingsReview, .reviewPrompt, .detailedModeOn,
        ]

        for analyticType in allCases {
            XCTAssertEqual(
                analyticType.stringValue(),
                analyticType.rawValue,
                "stringValue() should match rawValue for \(analyticType)"
            )
        }
    }

    // MARK: - Hashable

    func testHashable() {
        var set = Set<AnalyticType>()
        set.insert(.launchApp)
        set.insert(.addNewEvent)
        set.insert(.launchApp) // duplicate

        XCTAssertEqual(set.count, 2)
    }

    // MARK: - All Events Covered

    func testTotalEventCount() {
        let allCases: [AnalyticType] = [
            .launchApp, .addNewEvent, .editEvent,
            .updateCategory, .addNewCategory,
            .chooseIcon, .chooseTheme,
            .settingsReview, .reviewPrompt, .detailedModeOn,
        ]
        XCTAssertEqual(allCases.count, 10)
    }

    // MARK: - isSimulatorOrTestFlight

    func testIsSimulatorOrTestFlightReturnsBoolean() {
        // In test environment, this should return true (simulator)
        let result = isSimulatorOrTestFlight()
        XCTAssertTrue(result, "Tests run in simulator should return true")
    }
}
