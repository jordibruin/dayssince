//
//  LaunchTests.swift
//  DaysSinceUITests
//

import XCTest

/// Proves the `TestHooks` harness itself works: without a deterministic launch every other UI
/// suite is guesswork. If these fail, nothing else in the target is trustworthy.
@MainActor
final class LaunchTests: UITestCase {

    func testSeededLaunchReachesMainScreen() throws {
        let main = MainScreenRobot(app: launch()).awaitLoaded()

        XCTAssertTrue(main.event("✂️ Haircut").exists)
        XCTAssertTrue(main.newEventButton.exists)
    }

    /// The reset must run before any manager reads storage. A leftover `hasSeenOnboarding` from a
    /// previous run would silently skip onboarding and make the onboarding suite pass vacuously.
    func testCleanLaunchShowsOnboarding() throws {
        let app = launch(seedDemoData: false)

        OnboardingRobot(app: app).awaitLoaded()
        XCTAssertFalse(app.navigationBars.staticTexts["Events"].exists)
    }

    /// The intro paywall is suppressed by default, so a suite about anything else never has to
    /// dismiss it first.
    func testIntroPaywallSuppressedByDefault() throws {
        let app = launch()

        MainScreenRobot(app: app).awaitLoaded()
        XCTAssertFalse(PaywallRobot(app: app).title.exists)
    }

    func testKeepStateSurvivesRelaunch() throws {
        let main = MainScreenRobot(app: launch()).awaitLoaded()
        main.deleteEvent("✂️ Haircut")
        main.event("✂️ Haircut").awaitDisappearance()

        let relaunched = MainScreenRobot(app: relaunch()).awaitLoaded()
        XCTAssertTrue(relaunched.event("👯 Hung out with friends").exists)
        XCTAssertFalse(relaunched.event("✂️ Haircut").exists, "Deletion did not persist")
    }
}
