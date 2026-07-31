//
//  OnboardingTests.swift
//  DaysSinceUITests
//

import XCTest

/// First launch through to a real first event. This is the only flow every single user takes, and it
/// writes both `Defaults[.categories]` and the first item, so a break here is invisible to existing
/// installs and fatal to new ones.
@MainActor
final class OnboardingTests: UITestCase {

    /// `seedDemoData: false` is what makes the launch a genuine fresh install — the seed sets
    /// `hasSeenOnboarding`, which would skip the whole flow.
    private func launchFresh(subscribed: Bool = true) -> XCUIApplication {
        launch(seedDemoData: false, subscribed: subscribed)
    }

    func testCompletingOnboardingCreatesTheFirstEvent() throws {
        let app = launchFresh()

        let main = OnboardingRobot(app: app).completeFlow(categoryName: "Life", eventName: "✂️ Haircut")

        main.awaitLoaded()
        main.event("✂️ Haircut").awaitExistence()
    }

    func testTheFirstEventCanBeRenamedDuringOnboarding() throws {
        let app = launchFresh()

        let main = OnboardingRobot(app: app).completeFlow(
            categoryName: "Hobby",
            eventName: "🎮 Game night",
            renamedTo: "Board games"
        )

        main.awaitLoaded()
        main.event("Board games").awaitExistence()
        XCTAssertFalse(main.event("🎮 Game night").exists)
    }

    func testOnlyTheChosenCategoriesAreKept() throws {
        let app = launchFresh()

        let main = OnboardingRobot(app: app).completeFlow(categoryName: "Journal", eventName: "📓 Journaled")
        main.awaitLoaded()

        XCTAssertTrue(main.scrollToCategory("Journal").exists)
        XCTAssertFalse(main.categoryPill("Pet").exists, "An unselected category was created anyway")
    }

    func testOnboardingIsNotShownAgain() throws {
        let app = launchFresh()
        OnboardingRobot(app: app).completeFlow(categoryName: "Life", eventName: "✂️ Haircut").awaitLoaded()

        let relaunched = MainScreenRobot(app: relaunch()).awaitLoaded()

        XCTAssertFalse(OnboardingRobot(app: app).getStarted.exists, "Onboarding came back")
        XCTAssertTrue(relaunched.event("✂️ Haircut").exists, "The first event did not survive")
    }

    /// Onboarding must not be gated: a user who has not bought anything yet still has to be able to
    /// create their first event.
    func testOnboardingWorksWithoutPro() throws {
        let app = launchFresh(subscribed: false)

        let main = OnboardingRobot(app: app).completeFlow(categoryName: "Health", eventName: "💊 Vitamins refill")

        main.awaitLoaded()
        main.event("💊 Vitamins refill").awaitExistence()
    }
}
