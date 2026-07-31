//
//  SortingTests.swift
//  DaysSinceUITests
//

import XCTest

/// The five sort options and their persistence. Assertions are made on the *visible* prefix of the
/// list rather than all 16 seeded events — the list scrolls, so anything below the fold is absent
/// from the accessibility hierarchy. A correctly sorted prefix of a sorted list is still the claim.
@MainActor
final class SortingTests: UITestCase {

    /// Waits until the list settles on a new order. Re-sorting is a data change, so the previously
    /// captured names are from a stale snapshot for a frame or two.
    private func awaitOrder(
        _ main: MainScreenRobot,
        satisfying isSorted: @escaping ([String]) -> Bool,
        _ message: String,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let deadline = Date().addingTimeInterval(10)
        var last: [String] = []
        repeat {
            last = main.visibleEventNames
            if last.count > 1, isSorted(last) { return }
        } while Date() < deadline
        XCTFail("\(message) — got \(last)", file: file, line: line)
    }

    func testAlphabeticalAscending() throws {
        let main = MainScreenRobot(app: launch()).awaitLoaded()

        main.sort(by: "alphabeticallyAscending")

        awaitOrder(main, satisfying: { $0 == $0.sorted() }, "Expected names in ascending order")
    }

    func testAlphabeticalDescending() throws {
        let main = MainScreenRobot(app: launch()).awaitLoaded()

        main.sort(by: "alphabeticallyDescending")

        awaitOrder(main, satisfying: { $0 == $0.sorted(by: >) }, "Expected names in descending order")
    }

    /// "Days (New-Old)" is `daysAscending`: the smallest day count first.
    func testDaysAscendingPutsTheMostRecentFirst() throws {
        let main = MainScreenRobot(app: launch()).awaitLoaded()

        main.sort(by: "daysAscending")

        awaitOrder(main, satisfying: { names in
            let days = names.compactMap(SeedData.daysAgo)
            return days.count == names.count && days == days.sorted()
        }, "Expected ascending day counts")
    }

    func testDaysDescendingPutsTheOldestFirst() throws {
        let main = MainScreenRobot(app: launch()).awaitLoaded()

        main.sort(by: "daysDescending")

        awaitOrder(main, satisfying: { names in
            let days = names.compactMap(SeedData.daysAgo)
            return days.count == names.count && days == days.sorted(by: >)
        }, "Expected descending day counts")
    }

    /// `SortType.category` compares category *names* with `>`, so the groups come out reverse
    /// alphabetically rather than in the user's category order. Pinned as-is.
    func testCategorySortGroupsEventsByCategory() throws {
        let main = MainScreenRobot(app: launch()).awaitLoaded()

        main.sort(by: "category")

        awaitOrder(main, satisfying: { names in
            let categories = names.compactMap(SeedData.category)
            return categories.count == names.count && categories == categories.sorted(by: >)
        }, "Expected events grouped by category name, descending")
    }

    func testSortChoiceSurvivesRelaunch() throws {
        let main = MainScreenRobot(app: launch()).awaitLoaded()
        main.sort(by: "alphabeticallyDescending")
        awaitOrder(main, satisfying: { $0 == $0.sorted(by: >) }, "Sort did not apply before relaunch")

        let relaunched = MainScreenRobot(app: relaunch()).awaitLoaded()

        awaitOrder(relaunched, satisfying: { $0 == $0.sorted(by: >) }, "Sort choice did not persist")
    }

    /// The default is `daysAscending`, and a fresh install must not land on an arbitrary order.
    func testDefaultSortIsMostRecentFirst() throws {
        let main = MainScreenRobot(app: launch()).awaitLoaded()

        awaitOrder(main, satisfying: { names in
            let days = names.compactMap(SeedData.daysAgo)
            return days.count == names.count && days == days.sorted()
        }, "Expected the default sort to be ascending day counts")
    }
}
