//
//  CategoryFlowTests.swift
//  DaysSinceUITests
//

import XCTest

/// Category create / rename / delete, plus the refusal to delete a category that still has events —
/// the guard that stops a delete from orphaning user data.
@MainActor
final class CategoryFlowTests: UITestCase {

    func testAddCategoryAppearsAsAPill() throws {
        let main = MainScreenRobot(app: launch()).awaitLoaded()

        main.addCategory().awaitLoaded().type(name: "Reading").confirm()

        main.scrollToCategory("Reading").awaitExistence()
        XCTAssertEqual(main.categoryCount("Reading").label, "0 events")
    }

    func testAddCategorySurvivesRelaunch() throws {
        let main = MainScreenRobot(app: launch()).awaitLoaded()
        main.addCategory().awaitLoaded().type(name: "Chores").confirm()
        main.scrollToCategory("Chores").awaitExistence()

        let relaunched = MainScreenRobot(app: relaunch()).awaitLoaded()
        XCTAssertTrue(relaunched.scrollToCategory("Chores").exists)
    }

    func testCategoryFilterShowsOnlyItsOwnEvents() throws {
        let main = MainScreenRobot(app: launch()).awaitLoaded()

        let filtered = main.openCategory("Work").awaitLoaded()

        filtered.event("📊 Performance review").awaitExistence()
        XCTAssertTrue(filtered.event("💼 Resume update").exists)
        XCTAssertFalse(filtered.event("✂️ Haircut").exists, "A Life event leaked into the Work filter")
    }

    /// The pill count is the only place the category/event relationship is visible on the main
    /// screen, so it is what proves a rename carried through to the events.
    func testRenamingACategoryKeepsItsEvents() throws {
        let main = MainScreenRobot(app: launch()).awaitLoaded()

        main.editCategory("Work").awaitLoaded().type(name: "Career").confirm()

        main.categoryPill("Career").awaitExistence()
        XCTAssertEqual(main.categoryCount("Career").label, "2 events")
        XCTAssertFalse(main.categoryPill("Work").exists)
    }

    func testDeletingAnEmptyCategoryRemovesIt() throws {
        let main = MainScreenRobot(app: launch()).awaitLoaded()
        main.addCategory().awaitLoaded().type(name: "Temporary").confirm()
        main.scrollToCategory("Temporary").awaitExistence()

        main.deleteCategory("Temporary")
        main.confirmDeleteCategory()

        main.categoryPill("Temporary").awaitDisappearance()
    }

    /// From the pill's context menu the refusal is titled "Unable to Delete Category". The other
    /// entry point words it differently — see `testDeleteIsRefusedFromTheCategoryScreen`.
    func testDeleteIsRefusedFromThePillMenu() throws {
        let main = MainScreenRobot(app: launch()).awaitLoaded()

        main.deleteCategory("Work")

        let alert = app.alerts["Unable to Delete Category"]
        alert.awaitExistence()
        XCTAssertTrue(alert.staticTexts["Category contains existing events."].exists)

        alert.buttons.firstMatch.tapWhenReady()
        XCTAssertTrue(main.categoryPill("Work").exists, "A refused delete must leave the category alone")
    }

    func testDeleteIsRefusedFromTheCategoryScreen() throws {
        let main = MainScreenRobot(app: launch()).awaitLoaded()

        let filtered = main.openCategory("Health").awaitLoaded().tapDelete()

        filtered.blockedMessage.awaitExistence()
        filtered.dismissBlockedAlert()

        filtered.back().awaitLoaded()
        XCTAssertTrue(main.categoryPill("Health").exists)
    }

    /// Deleting the last event in a category is what unlocks deleting the category itself, so the
    /// guard has to be re-evaluated rather than decided once.
    func testEmptyingACategoryUnlocksDeletingIt() throws {
        let main = MainScreenRobot(app: launch()).awaitLoaded()

        main.deleteEvent("💧 Water filter change")
        main.event("💧 Water filter change").awaitDisappearance()
        main.scrollToCategory("Home")
        XCTAssertEqual(main.categoryCount("Home").label, "0 events")

        main.deleteCategory("Home")
        main.confirmDeleteCategory()

        main.categoryPill("Home").awaitDisappearance()
    }

    func testAddingAnEventFromACategoryScreenAssignsThatCategory() throws {
        let main = MainScreenRobot(app: launch()).awaitLoaded()

        main.openCategory("Friends")
            .awaitLoaded()
            .addEvent()
            .awaitLoaded()
            .type(name: "Called grandma")
            .save()

        let filtered = CategoryFilterRobot(app: app, categoryName: "Friends")
        filtered.event("Called grandma").awaitExistence()

        filtered.back().awaitLoaded()
        main.scrollToCategory("Friends")
        XCTAssertEqual(main.categoryCount("Friends").label, "2 events")
    }
}
