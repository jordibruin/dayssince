@testable import DaysSince
import Foundation
import Testing

/// The analytics events covered by this suite, paired with the exact string sent
/// to TelemetryDeck. Renaming any of these silently breaks dashboards, so the
/// strings are spelled out rather than derived from the enum.
private let trackedAnalyticCases: [(AnalyticType, String)] = [
    (.launchApp, "launchApp"),
    (.addNewEvent, "addNewEvent"),
    (.editEvent, "editEvent"),
    (.updateCategory, "updateCategory"),
    (.addNewCategory, "addNewCategory"),
    (.chooseIcon, "chooseIcon"),
    (.chooseTheme, "chooseTheme"),
    (.settingsReview, "settingsReview"),
    (.reviewPrompt, "reviewPrompt"),
    (.detailedModeOn, "detailedModeOn"),
]

@Suite("AnalyticType")
struct AnalyticsTypeTests {
    // MARK: - Raw Values

    @Test("raw values are stable", arguments: trackedAnalyticCases)
    func rawValues(analyticType: AnalyticType, expectedRawValue: String) {
        #expect(analyticType.rawValue == expectedRawValue)
    }

    // MARK: - String Value Consistency

    @Test("stringValue() matches rawValue", arguments: trackedAnalyticCases.map(\.0))
    func stringValueMatchesRawValue(analyticType: AnalyticType) {
        #expect(
            analyticType.stringValue() == analyticType.rawValue,
            "stringValue() should match rawValue for \(analyticType)"
        )
    }

    // MARK: - All Events Covered

    @Test("ten events are covered by these tests")
    func totalEventCount() {
        #expect(trackedAnalyticCases.count == 10)
    }

    // MARK: - Hashable

    @Test("duplicates collapse in a Set")
    func hashable() {
        var set = Set<AnalyticType>()
        set.insert(.launchApp)
        set.insert(.addNewEvent)
        set.insert(.launchApp) // duplicate

        #expect(set.count == 2)
    }

}

/// Global tier, despite looking pure: `isSimulatorOrTestFlight()` reads
/// `Bundle.main.appStoreReceiptURL`, and an active `SKTestSession` swaps that receipt for a
/// StoreKit-test one whose path matches neither marker. Run in parallel with
/// `SubscriptionStoreKitTests` it fails roughly one run in three.
extension GlobalStateSuite {

    @Suite("Analytics environment")
    struct AnalyticsEnvironmentTests {

        @Test("the simulator is treated as a non-production environment")
        func isSimulatorOrTestFlightUnderTest() {
            #expect(isSimulatorOrTestFlight())
        }
    }
}
