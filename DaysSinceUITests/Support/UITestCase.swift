//
//  UITestCase.swift
//  DaysSinceUITests
//

import XCTest

/// Base class for every UI suite. Owns launching the app with the `TestHooks` launch arguments
/// so no individual test has to remember the coarse `-uiTest` flag — forgetting it wouldn't fail
/// loudly, it would just let a test read the developer's real data and go flaky.
@MainActor
class UITestCase: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    override func tearDown() {
        app?.terminate()
        app = nil
    }

    /// - Parameters:
    ///   - seedDemoData: writes the 16 sample events and skips onboarding + migration.
    ///   - subscribed: forces the Pro entitlement. Defaults to `true` because most screens are
    ///     gated behind it and a test about sorting shouldn't be a test about the paywall.
    ///   - showPaywall: opts back into the once-per-install intro paywall.
    ///   - keepState: relaunches without wiping storage, for persistence assertions.
    @discardableResult
    func launch(
        seedDemoData: Bool = true,
        subscribed: Bool? = true,
        showOnboarding: Bool = false,
        showICloudMigration: Bool = false,
        showPaywall: Bool = false,
        keepState: Bool = false
    ) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = ["-uiTest"]

        if seedDemoData { app.launchArguments.append("-seedDemoData") }
        if showOnboarding { app.launchArguments.append("-showOnboarding") }
        if showICloudMigration { app.launchArguments.append("-showICloudMigration") }
        if showPaywall { app.launchArguments.append("-showPaywall") }
        if keepState { app.launchArguments.append("-keepState") }

        if let subscribed {
            app.launchEnvironment["UITEST_SUBSCRIBED"] = subscribed ? "1" : "0"
        }

        app.launch()
        self.app = app
        return app
    }

    /// Relaunches with the same flags, keeping whatever the previous launch persisted.
    @discardableResult
    func relaunch(
        seedDemoData: Bool = false,
        subscribed: Bool? = true,
        showPaywall: Bool = false
    ) -> XCUIApplication {
        app?.terminate()
        return launch(
            seedDemoData: seedDemoData,
            subscribed: subscribed,
            showPaywall: showPaywall,
            keepState: true
        )
    }
}

extension XCUIApplication {

    /// Scrolls until `element` shows up. A `Form` renders lazily, so a row below the fold is
    /// genuinely absent from the accessibility hierarchy rather than merely off screen — waiting
    /// for it without scrolling just times out.
    @discardableResult
    func scrollTo(
        _ element: XCUIElement,
        maxSwipes: Int = 10,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> XCUIElement {
        var swipes = 0
        while !(element.exists && element.isHittable) && swipes < maxSwipes {
            swipeUp()
            swipes += 1
        }
        XCTAssertTrue(
            element.exists && element.isHittable,
            "Could not scroll \(element) into view after \(maxSwipes) swipes",
            file: file,
            line: line
        )
        return element
    }
}

extension XCUIElement {

    /// Every assertion goes through a wait: SwiftUI mounts views a frame or two after the tap that
    /// caused them, so a bare `exists` check is a race even with animations disabled.
    @discardableResult
    func awaitExistence(
        _ timeout: TimeInterval = 10,
        _ message: String? = nil,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> XCUIElement {
        XCTAssertTrue(
            waitForExistence(timeout: timeout),
            message ?? "Expected \(self) to exist within \(timeout)s",
            file: file,
            line: line
        )
        return self
    }

    func awaitDisappearance(
        _ timeout: TimeInterval = 10,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let gone = XCTNSPredicateExpectation(
            predicate: NSPredicate(format: "exists == false"),
            object: self
        )
        XCTAssertEqual(
            XCTWaiter().wait(for: [gone], timeout: timeout),
            .completed,
            "Expected \(self) to disappear within \(timeout)s",
            file: file,
            line: line
        )
    }

    @discardableResult
    func awaitHittable(
        _ timeout: TimeInterval = 10,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> XCUIElement {
        awaitExistence(timeout, file: file, line: line)
        let hittable = XCTNSPredicateExpectation(
            predicate: NSPredicate(format: "isHittable == true"),
            object: self
        )
        XCTAssertEqual(
            XCTWaiter().wait(for: [hittable], timeout: timeout),
            .completed,
            "Expected \(self) to become hittable within \(timeout)s",
            file: file,
            line: line
        )
        return self
    }

    /// Taps only once the element is actually hittable. A visible-but-not-yet-hittable element is
    /// the usual cause of a tap that silently does nothing during a sheet transition.
    func tapWhenReady(_ timeout: TimeInterval = 10, file: StaticString = #filePath, line: UInt = #line) {
        awaitHittable(timeout, file: file, line: line)
        tap()
    }

    /// A SwiftUI `Toggle` in a `Form` publishes the whole row as the switch, and the row's centre is
    /// the label — tapping there lands on text and silently leaves the value unchanged. The control
    /// itself sits at the trailing edge.
    func flipSwitch(_ timeout: TimeInterval = 10, file: StaticString = #filePath, line: UInt = #line) {
        awaitHittable(timeout, file: file, line: line)
        coordinate(withNormalizedOffset: CGVector(dx: 0.9, dy: 0.5)).tap()
    }

    /// Clears an existing value before typing. `typeText` alone appends, which turns an edit test
    /// into an assertion about concatenated strings.
    func replaceText(with text: String) {
        tapWhenReady()
        if let current = value as? String, !current.isEmpty {
            typeText(String(repeating: XCUIKeyboardKey.delete.rawValue, count: current.count))
        }
        typeText(text)
    }
}
