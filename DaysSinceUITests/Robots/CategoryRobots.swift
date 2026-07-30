//
//  CategoryRobots.swift
//  DaysSinceUITests
//

import XCTest

/// Serves both the add and edit category sheets — they are near-identical views whose identifiers
/// differ only by prefix.
@MainActor
struct CategorySheetRobot {
    let app: XCUIApplication
    let prefix: String

    var nameField: XCUIElement { app.textFields["\(prefix).name"] }
    var confirmButton: XCUIElement { app.buttons[prefix == "addCategory" ? "addCategory.add" : "editCategory.save"] }

    @discardableResult
    func awaitLoaded() -> Self {
        nameField.awaitExistence()
        return self
    }

    @discardableResult
    func type(name: String) -> Self {
        nameField.replaceText(with: name)
        return self
    }

    @discardableResult
    func choose(emoji: String) -> Self {
        app.buttons["\(prefix).emoji.\(emoji)"].tapWhenReady()
        return self
    }

    /// `colorID` is `CategoryColor.id` — "Work", "MarioBlue", and so on.
    @discardableResult
    func choose(colorID: String) -> Self {
        app.buttons["\(prefix).color.\(colorID)"].tapWhenReady()
        return self
    }

    @discardableResult
    func confirm() -> Self {
        confirmButton.tapWhenReady()
        return self
    }
}

@MainActor
struct CategoryFilterRobot {
    let app: XCUIApplication
    let categoryName: String

    var title: XCUIElement { app.navigationBars.staticTexts[categoryName] }
    var deleteButton: XCUIElement { app.buttons["categoryFilter.delete"] }
    var editButton: XCUIElement { app.buttons["categoryFilter.edit"] }
    var addEventButton: XCUIElement { app.buttons["categoryFilter.addEvent"] }

    /// The two "can't delete" and "confirm delete" presentations share the title "Delete Category",
    /// so they are told apart by their message instead.
    var blockedMessage: XCUIElement {
        app.staticTexts["Can't delete category. Category contains existing events."]
    }

    @discardableResult
    func awaitLoaded() -> Self {
        title.awaitExistence()
        return self
    }

    func event(_ name: String) -> XCUIElement { app.staticTexts["event.name.\(name)"] }

    @discardableResult
    func tapDelete() -> Self {
        deleteButton.tapWhenReady()
        return self
    }

    @discardableResult
    func confirmDelete() -> Self {
        app.buttons["Delete"].tapWhenReady()
        return self
    }

    @discardableResult
    func dismissBlockedAlert() -> Self {
        app.alerts.buttons.firstMatch.tapWhenReady()
        return self
    }

    @discardableResult
    func openEdit() -> CategorySheetRobot {
        editButton.tapWhenReady()
        return CategorySheetRobot(app: app, prefix: "editCategory")
    }

    @discardableResult
    func addEvent() -> AddEventRobot {
        addEventButton.tapWhenReady()
        return AddEventRobot(app: app)
    }

    @discardableResult
    func back() -> MainScreenRobot {
        app.navigationBars.buttons.firstMatch.tapWhenReady()
        return MainScreenRobot(app: app)
    }
}
