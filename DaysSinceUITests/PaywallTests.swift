//
//  PaywallTests.swift
//  DaysSinceUITests
//

import XCTest

/// Pro gating. Every mutating action on the main screen is behind the entitlement, so a regression
/// here either locks paying users out or gives the app away. Nothing here touches StoreKit: the
/// entitlement is forced with `UITEST_SUBSCRIBED`, and purchasing itself is covered by
/// `SubscriptionStoreKitTests`, which can drive `SKTestSession` directly.
@MainActor
final class PaywallTests: UITestCase {

    func testLockedUserCannotAddAnEvent() throws {
        let app = launch(subscribed: false)
        let main = MainScreenRobot(app: app).awaitLoaded()

        main.newEventButton.tapWhenReady()

        PaywallRobot(app: app).awaitLoaded()
        XCTAssertFalse(AddEventRobot(app: app).nameField.exists, "A locked user reached the add form")
    }

    func testLockedUserCannotAddACategory() throws {
        let app = launch(subscribed: false)
        let main = MainScreenRobot(app: app).awaitLoaded()

        main.newCategoryButton.tapWhenReady()

        PaywallRobot(app: app).awaitLoaded()
        XCTAssertFalse(
            CategorySheetRobot(app: app, prefix: "addCategory").nameField.exists,
            "A locked user reached the add-category sheet"
        )
    }

    func testLockedUserCannotDeleteACategory() throws {
        let app = launch(subscribed: false)
        let main = MainScreenRobot(app: app).awaitLoaded()

        main.openCategory("Work").awaitLoaded().tapDelete()

        PaywallRobot(app: app).awaitLoaded()
    }

    func testUnlockedUserReachesTheAddForm() throws {
        let app = launch(subscribed: true)

        MainScreenRobot(app: app).awaitLoaded().addEvent().awaitLoaded()

        XCTAssertFalse(PaywallRobot(app: app).title.exists)
    }

    /// The events list itself is never gated — a lapsed subscriber must still be able to read their
    /// own data.
    func testLockedUserCanStillSeeTheirEvents() throws {
        let main = MainScreenRobot(app: launch(subscribed: false)).awaitLoaded()

        XCTAssertTrue(main.event("✂️ Haircut").exists)
        XCTAssertTrue(main.days("✂️ Haircut").exists)
    }

    func testSettingsReportsTheEntitlement() throws {
        let subscribed = MainScreenRobot(app: launch(subscribed: true)).awaitLoaded().openSettings().awaitLoaded()
        XCTAssertTrue(subscribed.proButton.staticTexts["Active"].exists)

        let locked = MainScreenRobot(app: launch(subscribed: false)).awaitLoaded().openSettings().awaitLoaded()
        XCTAssertTrue(locked.proButton.staticTexts["Upgrade"].exists)
    }

    func testPaywallFromSettingsCanBeDismissed() throws {
        let app = launch(subscribed: false)
        let paywall = MainScreenRobot(app: app).awaitLoaded().openSettings().awaitLoaded().openPaywall().awaitLoaded()

        paywall.close()

        SettingsRobot(app: app).awaitLoaded()
        XCTAssertFalse(paywall.title.exists)
    }

    /// The intro paywall is once per install. The relaunch passes `-showPaywall` again on purpose:
    /// what must suppress it is the stored `hasSeenPaywall`, not the absence of the flag.
    func testIntroPaywallIsShownOnlyOnce() throws {
        let app = launch(subscribed: false, showPaywall: true)
        let paywall = PaywallRobot(app: app).awaitLoaded()
        paywall.close()
        MainScreenRobot(app: app).awaitLoaded()

        let relaunched = relaunch(subscribed: false, showPaywall: true)

        MainScreenRobot(app: relaunched).awaitLoaded()
        XCTAssertFalse(PaywallRobot(app: relaunched).title.exists, "The intro paywall came back")
    }
}
