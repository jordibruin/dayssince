//
//  MainScreenRobot.swift
//  DaysSinceUITests
//

import XCTest

/// Page object for the events list. Elements are looked up on every access rather than cached:
/// SwiftUI replaces `ForEach` children wholesale on a data change, and a cached `XCUIElement`
/// keeps pointing at the old snapshot.
@MainActor
struct MainScreenRobot {
    let app: XCUIApplication

    // MARK: - Elements

    var title: XCUIElement { app.navigationBars.staticTexts["Events"] }
    var settingsButton: XCUIElement { app.buttons["main.settings"] }
    var themeButton: XCUIElement { app.buttons["main.theme"] }
    var newEventButton: XCUIElement { app.buttons["main.newEvent"] }
    var newCategoryButton: XCUIElement { app.buttons["main.newCategory"] }
    var sortMenu: XCUIElement { app.buttons["main.sortMenu"] }

    func event(_ name: String) -> XCUIElement { app.staticTexts["event.name.\(name)"] }
    func days(_ name: String) -> XCUIElement { app.staticTexts["event.days.\(name)"] }
    func categoryPill(_ name: String) -> XCUIElement { app.buttons["category.pill.\(name)"] }
    func categoryCount(_ name: String) -> XCUIElement { app.staticTexts["category.count.\(name)"] }

    /// Event names in the order the list renders them, which is what a sort assertion needs.
    var visibleEventNames: [String] {
        app.staticTexts
            .matching(NSPredicate(format: "identifier BEGINSWITH %@", "event.name."))
            .allElementsBoundByIndex
            .map { String($0.identifier.dropFirst("event.name.".count)) }
    }

    /// The horizontal category strip. It cannot be taken as the first `scrollViews` match: the
    /// full-screen vertical event list comes first in the hierarchy and *also* contains the pills,
    /// so swiping that one scrolls nothing horizontally and silently does nothing. The strip is
    /// the short one.
    private var categoryStrip: XCUIElement {
        let short = app.scrollViews.allElementsBoundByIndex.first { $0.frame.height < app.frame.height / 2 }
        return short ?? app.scrollViews.firstMatch
    }

    // MARK: - Actions

    @discardableResult
    func awaitLoaded() -> Self {
        title.awaitExistence(20, "Main screen never appeared — check the launch arguments")
        return self
    }

    /// The strip is a `LazyHStack`, so a pill past the fold does not exist yet, and one that is
    /// only half revealed has a frame outside the window and no valid activation point. Both are
    /// fixed by scrolling; the frame is compared directly because querying `isHittable` on an
    /// off-window element raises an error rather than returning false.
    @discardableResult
    func scrollToCategory(_ name: String, maxSwipes: Int = 8) -> XCUIElement {
        revealCategoryStrip()
        let pill = categoryPill(name)
        var swipes = 0
        while swipes < maxSwipes, !(pill.exists && app.frame.contains(pill.frame)) {
            categoryStrip.swipeLeft()
            swipes += 1
        }
        return pill
    }

    /// The strip scrolls away with the event list, and once it is above the top of the window a
    /// swipe on it fails outright ("visible frame is empty") rather than doing nothing.
    private func revealCategoryStrip(maxSwipes: Int = 5) {
        var swipes = 0
        while swipes < maxSwipes, !app.frame.contains(categoryStrip.frame) {
            app.swipeDown()
            swipes += 1
        }
    }

    @discardableResult
    func tapEvent(_ name: String) -> EditEventRobot {
        event(name).tapWhenReady()
        return EditEventRobot(app: app)
    }

    @discardableResult
    func addEvent() -> AddEventRobot {
        newEventButton.tapWhenReady()
        return AddEventRobot(app: app)
    }

    @discardableResult
    func addCategory() -> CategorySheetRobot {
        newCategoryButton.tapWhenReady()
        return CategorySheetRobot(app: app, prefix: "addCategory")
    }

    @discardableResult
    func openSettings() -> SettingsRobot {
        settingsButton.tapWhenReady()
        return SettingsRobot(app: app)
    }

    @discardableResult
    func openThemes() -> ThemeRobot {
        themeButton.tapWhenReady()
        return ThemeRobot(app: app)
    }

    @discardableResult
    func openCategory(_ name: String) -> CategoryFilterRobot {
        scrollToCategory(name).tapWhenReady()
        return CategoryFilterRobot(app: app, categoryName: name)
    }

    /// Menu content lives in a separate presentation, so items are queried on `app` rather than
    /// on the menu element itself.
    @discardableResult
    func sort(by rawValue: String) -> Self {
        sortMenu.tapWhenReady()
        app.buttons["sort.\(rawValue)"].tapWhenReady()
        return self
    }

    /// The event's own context menu — the only way to reach "Today"/"Yesterday"/"Delete", since
    /// the graphical DatePicker has no addressable field.
    @discardableResult
    func longPressEvent(_ name: String) -> Self {
        event(name).awaitExistence()
        event(name).press(forDuration: 1.2)
        return self
    }

    @discardableResult
    func deleteEvent(_ name: String) -> Self {
        longPressEvent(name)
        app.buttons["event.menu.delete"].tapWhenReady()
        // The confirmation is a `confirmationDialog`, so its buttons are addressed by label.
        app.buttons["Delete"].tapWhenReady()
        return self
    }

    /// The category pill's own context menu. Its delete path words the "category is not empty"
    /// refusal differently from `CategoryFilteredView`'s, so both are worth exercising.
    @discardableResult
    func longPressCategory(_ name: String) -> Self {
        scrollToCategory(name).awaitExistence()
        categoryPill(name).press(forDuration: 1.2)
        return self
    }

    @discardableResult
    func deleteCategory(_ name: String) -> Self {
        longPressCategory(name)
        app.buttons["category.menu.delete"].tapWhenReady()
        return self
    }

    @discardableResult
    func confirmDeleteCategory() -> Self {
        app.buttons["Delete"].tapWhenReady()
        return self
    }

    @discardableResult
    func editCategory(_ name: String) -> CategorySheetRobot {
        longPressCategory(name)
        app.buttons["category.menu.edit"].tapWhenReady()
        return CategorySheetRobot(app: app, prefix: "editCategory")
    }

    @discardableResult
    func markEventDoneToday(_ name: String) -> Self {
        longPressEvent(name)
        app.buttons["event.menu.today"].tapWhenReady()
        return self
    }
}
