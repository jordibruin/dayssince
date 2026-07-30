//
//  SettingsRobots.swift
//  DaysSinceUITests
//

import XCTest

@MainActor
struct SettingsRobot {
    let app: XCUIApplication

    var title: XCUIElement { app.navigationBars.staticTexts["Settings"] }
    var closeButton: XCUIElement { app.buttons["settings.close"] }
    var proButton: XCUIElement { app.buttons["settings.pro"] }
    var appIconsButton: XCUIElement { app.buttons["settings.appIcons"] }
    var exportButton: XCUIElement { app.buttons["settings.export"] }

    @discardableResult
    func awaitLoaded() -> Self {
        title.awaitExistence()
        return self
    }

    /// The row can start below the fold, and a `Form` row that has not been rendered does not exist
    /// in the hierarchy at all.
    @discardableResult
    func openExport() -> ExportRobot {
        app.scrollTo(exportButton)
        exportButton.tapWhenReady()
        return ExportRobot(app: app)
    }

    @discardableResult
    func openPaywall() -> PaywallRobot {
        proButton.tapWhenReady()
        return PaywallRobot(app: app)
    }

    @discardableResult
    func close() -> MainScreenRobot {
        closeButton.tapWhenReady()
        return MainScreenRobot(app: app)
    }
}

@MainActor
struct ExportRobot {
    let app: XCUIApplication

    var title: XCUIElement { app.navigationBars.staticTexts["Export Data"] }
    var counts: XCUIElement { app.staticTexts["export.counts"] }
    var closeButton: XCUIElement { app.buttons["export.close"] }

    /// `fileExtension` is `ExportFormat.fileExtension` — "json", "csv", "txt".
    func format(_ fileExtension: String) -> XCUIElement { app.buttons["export.\(fileExtension)"] }

    @discardableResult
    func awaitLoaded() -> Self {
        title.awaitExistence()
        return self
    }

    /// The share sheet is a system presentation, so its arrival is detected by the Activity View
    /// rather than by anything the app owns.
    @discardableResult
    func export(_ fileExtension: String) -> Self {
        format(fileExtension).tapWhenReady()
        app.otherElements["ActivityListView"].awaitExistence(15, "Share sheet never appeared")
        return self
    }

    @discardableResult
    func dismissShareSheet() -> Self {
        let close = app.buttons["Close"]
        if close.waitForExistence(timeout: 3) {
            close.tap()
        } else {
            app.otherElements["ActivityListView"].swipeDown()
        }
        return self
    }
}

@MainActor
struct ThemeRobot {
    let app: XCUIApplication

    var title: XCUIElement { app.staticTexts["Themes"] }

    func swatch(_ id: String) -> XCUIElement { app.buttons["theme.\(id)"] }

    @discardableResult
    func awaitLoaded() -> Self {
        title.awaitExistence()
        return self
    }

    @discardableResult
    func select(_ id: String) -> Self {
        swatch(id).tapWhenReady()
        return self
    }

    /// Sheet has no close control of its own, so it is dismissed by dragging it down.
    @discardableResult
    func dismiss() -> MainScreenRobot {
        app.swipeDown()
        return MainScreenRobot(app: app)
    }
}

@MainActor
struct PaywallRobot {
    let app: XCUIApplication

    var title: XCUIElement { app.staticTexts["paywall.title"] }
    var continueButton: XCUIElement { app.buttons["paywall.continue"] }
    var restoreButton: XCUIElement { app.buttons["paywall.restore"] }
    var closeButton: XCUIElement { app.buttons["paywall.close"] }

    func product(_ id: String) -> XCUIElement { app.otherElements["paywall.product.\(id)"] }

    @discardableResult
    func awaitLoaded() -> Self {
        title.awaitExistence(15)
        return self
    }

    @discardableResult
    func select(_ id: String) -> Self {
        product(id).tapWhenReady()
        return self
    }

    @discardableResult
    func close() -> Self {
        closeButton.tapWhenReady()
        return self
    }
}

@MainActor
struct MigrationRobot {
    let app: XCUIApplication

    var syncingTitle: XCUIElement { app.staticTexts["Syncing Your Events"] }
    var doneTitle: XCUIElement { app.staticTexts["All Done!"] }
    var continueButton: XCUIElement { app.buttons["migration.continue"] }

    @discardableResult
    func awaitCompleted() -> Self {
        doneTitle.awaitExistence(15, "Migration never finished")
        return self
    }

    @discardableResult
    func `continue`() -> MainScreenRobot {
        continueButton.tapWhenReady()
        return MainScreenRobot(app: app)
    }
}

@MainActor
struct OnboardingRobot {
    let app: XCUIApplication

    var getStarted: XCUIElement { app.buttons["onboarding.getStarted"] }
    var eventNameField: XCUIElement { app.textFields["onboarding.eventName"] }

    func category(_ name: String) -> XCUIElement { app.buttons["onboarding.category.\(name)"] }
    func event(_ name: String) -> XCUIElement { app.buttons["onboarding.event.\(name)"] }

    @discardableResult
    func awaitLoaded() -> Self {
        getStarted.awaitExistence(20, "Onboarding never appeared")
        return self
    }

    /// Walks the full eight-page flow. Every `continue` has a screen-specific identifier because
    /// a NavigationStack keeps earlier pages in the hierarchy, where a shared identifier would
    /// resolve to the stale one.
    @discardableResult
    func completeFlow(categoryName: String, eventName: String, renamedTo: String? = nil) -> MainScreenRobot {
        awaitLoaded()
        getStarted.tapWhenReady()

        category(categoryName).tapWhenReady()
        app.buttons["onboarding.categories.continue"].tapWhenReady()

        event(eventName).tapWhenReady()
        app.buttons["onboarding.pickEvent.continue"].tapWhenReady()

        if let renamedTo {
            eventNameField.replaceText(with: renamedTo)
        }
        app.buttons["onboarding.createEvent"].tapWhenReady()

        app.buttons["onboarding.yay"].tapWhenReady()
        app.buttons["onboarding.widgetPreview.continue"].tapWhenReady()
        app.buttons["onboarding.features.continue"].tapWhenReady()
        app.buttons["onboarding.letsGo"].tapWhenReady()

        return MainScreenRobot(app: app)
    }
}
