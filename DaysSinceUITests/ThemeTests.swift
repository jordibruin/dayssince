//
//  ThemeTests.swift
//  DaysSinceUITests
//

import XCTest

/// Theme selection. The swatches are `Circle`s promoted to accessibility elements, and selection is
/// exposed as an `accessibilityValue` — there is no other way to read it, since the only visible
/// difference is a colour.
@MainActor
final class ThemeTests: UITestCase {

    func testDefaultThemeIsSelectedOnAFreshInstall() throws {
        let main = MainScreenRobot(app: launch()).awaitLoaded()

        let themes = main.openThemes().awaitLoaded()

        XCTAssertEqual(themes.swatch("default").value as? String, "selected")
    }

    func testSelectingAThemeMarksItSelected() throws {
        let main = MainScreenRobot(app: launch()).awaitLoaded()

        let themes = main.openThemes().awaitLoaded().select("zelda")

        XCTAssertEqual(themes.swatch("zelda").value as? String, "selected")
        XCTAssertEqual(themes.swatch("default").value as? String, "unselected", "Only one theme may be selected")
    }

    func testThemeChoiceSurvivesRelaunch() throws {
        let main = MainScreenRobot(app: launch()).awaitLoaded()
        main.openThemes().awaitLoaded().select("marioRedBlue").dismiss().awaitLoaded()

        let relaunched = MainScreenRobot(app: relaunch()).awaitLoaded()

        let themes = relaunched.openThemes().awaitLoaded()
        XCTAssertEqual(themes.swatch("marioRedBlue").value as? String, "selected")
    }

    /// A locked user tapping the palette gets the paywall instead of the theme sheet — the gate that
    /// makes themes a Pro feature.
    func testThemesAreGatedBehindPro() throws {
        let app = launch(subscribed: false)
        MainScreenRobot(app: app).awaitLoaded().themeButton.tapWhenReady()

        PaywallRobot(app: app).awaitLoaded()
        XCTAssertFalse(ThemeRobot(app: app).title.exists, "A locked user must not reach the theme sheet")
    }
}
