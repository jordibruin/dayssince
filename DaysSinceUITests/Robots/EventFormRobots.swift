//
//  EventFormRobots.swift
//  DaysSinceUITests
//

import XCTest

/// The add-event sheet. The graphical `DatePicker` has no addressable field, so a test that needs
/// a specific date sets it afterwards through the event's context menu instead.
@MainActor
struct AddEventRobot {
    let app: XCUIApplication

    var nameField: XCUIElement { app.textFields["addItem.name"] }
    var remindersToggle: XCUIElement { app.switches["addItem.remindersToggle"] }
    var saveButton: XCUIElement { app.buttons["addItem.save"] }
    var closeButton: XCUIElement { app.buttons["addItem.close"] }

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
    func choose(category: String) -> Self {
        app.buttons["form.category.\(category)"].tapWhenReady()
        return self
    }

    @discardableResult
    func enableReminders(_ cadence: String? = nil) -> Self {
        app.scrollTo(remindersToggle)
        remindersToggle.flipSwitch()
        if let cadence {
            // Segmented picker segments are addressed by their label text.
            let segment = app.buttons[cadence]
            app.scrollTo(segment)
            segment.tapWhenReady()
        }
        return self
    }

    @discardableResult
    func save() -> MainScreenRobot {
        saveButton.tapWhenReady()
        return MainScreenRobot(app: app)
    }

    @discardableResult
    func cancel() -> MainScreenRobot {
        closeButton.tapWhenReady()
        return MainScreenRobot(app: app)
    }
}

@MainActor
struct EditEventRobot {
    let app: XCUIApplication

    var nameField: XCUIElement { app.textFields["editItem.name"] }
    var remindersToggle: XCUIElement { app.switches["editItem.remindersToggle"] }
    var saveButton: XCUIElement { app.buttons["editItem.save"] }
    var closeButton: XCUIElement { app.buttons["editItem.close"] }

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

    /// The reminders section sits below a graphical DatePicker and the category list, so it has to
    /// be scrolled to before it exists at all.
    @discardableResult
    func scrollToReminders() -> Self {
        app.scrollTo(remindersToggle)
        return self
    }

    @discardableResult
    func toggleReminders() -> Self {
        scrollToReminders()
        remindersToggle.flipSwitch()
        return self
    }

    @discardableResult
    func choose(cadence: String) -> Self {
        let segment = app.buttons[cadence]
        app.scrollTo(segment)
        segment.tapWhenReady()
        return self
    }

    @discardableResult
    func save() -> MainScreenRobot {
        saveButton.tapWhenReady()
        return MainScreenRobot(app: app)
    }

    @discardableResult
    func cancel() -> MainScreenRobot {
        closeButton.tapWhenReady()
        return MainScreenRobot(app: app)
    }
}
