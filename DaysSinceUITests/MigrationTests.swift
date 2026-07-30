//
//  MigrationTests.swift
//  DaysSinceUITests
//

import XCTest

/// The one-time iCloud migration screen, shown to users who already had events before iCloud sync
/// existed. `-showICloudMigration` reproduces that state (`hasSeenOnboarding` set,
/// `iCloudMigrationComplete` not). The migration writes to an in-memory key-value store under
/// `-uiTest`, so nothing here can reach the developer's real iCloud account.
@MainActor
final class MigrationTests: UITestCase {

    func testMigrationCompletesAndReportsWhatItSynced() throws {
        let app = launch(showICloudMigration: true)

        let migration = MigrationRobot(app: app).awaitCompleted()

        XCTAssertTrue(
            app.staticTexts["16 events and 9 categories synced to iCloud."].exists,
            "The summary should describe the seeded data"
        )
        migration.continue().awaitLoaded()
    }

    func testMigrationLeavesTheEventsIntact() throws {
        let app = launch(showICloudMigration: true)

        let main = MigrationRobot(app: app).awaitCompleted().continue().awaitLoaded()

        main.event("✂️ Haircut").awaitExistence()
        XCTAssertTrue(main.event("🧘 Meditation").exists)
    }

    func testMigrationIsNotShownAgain() throws {
        let app = launch(showICloudMigration: true)
        MigrationRobot(app: app).awaitCompleted().continue().awaitLoaded()

        let relaunched = relaunch()
        MainScreenRobot(app: relaunched).awaitLoaded()

        XCTAssertFalse(
            MigrationRobot(app: relaunched).syncingTitle.exists,
            "The migration screen came back after it had completed"
        )
    }
}
