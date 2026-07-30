//
//  ExportTests.swift
//  DaysSinceUITests
//

import XCTest

/// Export is the user's only route to their data outside the app, so the claim worth testing is that
/// every format reaches the share sheet and that the counts describe the real data. The file
/// *contents* are covered by `ExportFormatterTests`, which can assert on them precisely.
@MainActor
final class ExportTests: UITestCase {

    private func openExport() -> ExportRobot {
        MainScreenRobot(app: launch())
            .awaitLoaded()
            .openSettings()
            .awaitLoaded()
            .openExport()
            .awaitLoaded()
    }

    func testCountsDescribeTheSeededData() throws {
        let export = openExport()

        XCTAssertEqual(export.counts.label, "16 events in 9 categories")
    }

    func testCountsFollowADeletion() throws {
        let main = MainScreenRobot(app: launch()).awaitLoaded()
        main.deleteEvent("🎁 Birthday gift")
        main.event("🎁 Birthday gift").awaitDisappearance()

        let export = main.openSettings().awaitLoaded().openExport().awaitLoaded()

        XCTAssertEqual(export.counts.label, "15 events in 9 categories")
    }

    func testJSONExportOpensTheShareSheet() throws {
        openExport().export("json").dismissShareSheet()
    }

    func testCSVExportOpensTheShareSheet() throws {
        openExport().export("csv").dismissShareSheet()
    }

    func testPlainTextExportOpensTheShareSheet() throws {
        openExport().export("txt").dismissShareSheet()
    }

    func testAllThreeFormatsAreOffered() throws {
        let export = openExport()

        for fileExtension in ["json", "csv", "txt"] {
            XCTAssertTrue(export.format(fileExtension).exists, "Missing the \(fileExtension) option")
        }
    }
}
