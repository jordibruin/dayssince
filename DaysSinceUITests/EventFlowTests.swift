//
//  EventFlowTests.swift
//  DaysSinceUITests
//

import XCTest

/// Add / edit / delete an event. This is the flow that loses user data if it breaks, so each test
/// asserts through a relaunch where persistence is the actual claim.
@MainActor
final class EventFlowTests: UITestCase {

    func testAddEventAppearsInList() throws {
        let main = MainScreenRobot(app: launch()).awaitLoaded()

        main.addEvent()
            .awaitLoaded()
            .type(name: "Watered the plants")
            .save()

        main.event("Watered the plants").awaitExistence()
    }

    func testAddEventSurvivesRelaunch() throws {
        let main = MainScreenRobot(app: launch()).awaitLoaded()
        main.addEvent().awaitLoaded().type(name: "Changed the sheets").save()
        main.event("Changed the sheets").awaitExistence()

        let relaunched = MainScreenRobot(app: relaunch()).awaitLoaded()
        XCTAssertTrue(relaunched.event("Changed the sheets").exists)
    }

    func testCancellingAddDiscardsTheEvent() throws {
        let main = MainScreenRobot(app: launch()).awaitLoaded()

        main.addEvent().awaitLoaded().type(name: "Never saved").cancel()

        main.newEventButton.awaitExistence()
        XCTAssertFalse(main.event("Never saved").exists)
    }

    func testSaveIsDisabledWithoutAName() throws {
        let main = MainScreenRobot(app: launch()).awaitLoaded()

        let add = main.addEvent().awaitLoaded()
        XCTAssertFalse(add.saveButton.isEnabled, "An unnamed event must not be savable")

        add.type(name: "x")
        XCTAssertTrue(add.saveButton.isEnabled)
    }

    func testRenameEvent() throws {
        let main = MainScreenRobot(app: launch()).awaitLoaded()

        main.tapEvent("📓 Journaled")
            .awaitLoaded()
            .type(name: "Wrote in my journal")
            .save()

        main.event("Wrote in my journal").awaitExistence()
        XCTAssertFalse(main.event("📓 Journaled").exists)
    }

    func testDeleteEventRemovesItPermanently() throws {
        let main = MainScreenRobot(app: launch()).awaitLoaded()
        main.event("🎮 Game night").awaitExistence()

        main.deleteEvent("🎮 Game night")
        main.event("🎮 Game night").awaitDisappearance()

        let relaunched = MainScreenRobot(app: relaunch()).awaitLoaded()
        XCTAssertFalse(relaunched.event("🎮 Game night").exists)
    }

    /// The context menu is the only way to change a date: the graphical `DatePicker` exposes no
    /// field XCUITest can address.
    func testMarkingDoneTodayResetsTheCount() throws {
        let main = MainScreenRobot(app: launch()).awaitLoaded()
        main.days("🏥 Dentist visit").awaitExistence()

        main.markEventDoneToday("🏥 Dentist visit")

        let days = main.days("🏥 Dentist visit")
        let reset = XCTNSPredicateExpectation(
            predicate: NSPredicate(format: "label CONTAINS[c] %@", "0"),
            object: days
        )
        XCTAssertEqual(
            XCTWaiter().wait(for: [reset], timeout: 10),
            .completed,
            "Expected the day count to reset, got \(days.label)"
        )
    }

    func testReminderToggleRoundTrips() throws {
        let main = MainScreenRobot(app: launch()).awaitLoaded()

        let edit = main.tapEvent("🧘 Meditation").awaitLoaded().scrollToReminders()
        XCTAssertEqual(edit.remindersToggle.value as? String, "0", "Seeded events start without reminders")

        edit.toggleReminders().choose(cadence: "Weekly").save()

        let reopened = main.tapEvent("🧘 Meditation").awaitLoaded().scrollToReminders()
        XCTAssertEqual(reopened.remindersToggle.value as? String, "1")
        XCTAssertTrue(reopened.app.buttons["Weekly"].isSelected, "The saved cadence should be reselected")
        reopened.cancel()
    }
}
