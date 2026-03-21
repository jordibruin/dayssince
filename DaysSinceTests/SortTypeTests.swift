@testable import DaysSince

import XCTest

final class SortTypeTests: XCTestCase {
    let workCategory = DaysSince.Category(name: "Work", emoji: "lightbulb", color: .work)
    let lifeCategory = DaysSince.Category(name: "Life", emoji: "leaf", color: .life)

    func makeItem(name: String, daysAgo: Int, category: DaysSince.Category? = nil) -> DSItem {
        let date = Calendar.current.date(byAdding: .day, value: -daysAgo, to: Date.now)!
        return DSItem(
            id: UUID(),
            name: name,
            category: category ?? workCategory,
            dateLastDone: date,
            remindersEnabled: false
        )
    }

    // MARK: - All Cases

    func testAllCasesCount() {
        XCTAssertEqual(SortType.allCases.count, 5)
    }

    // MARK: - Names

    func testSortTypeNames() {
        XCTAssertEqual(SortType.alphabeticallyAscending.name, "Alphabetical (A-Z)")
        XCTAssertEqual(SortType.alphabeticallyDescending.name, "Alphabetical (Z-A)")
        XCTAssertEqual(SortType.daysAscending.name, "Days (New-Old)")
        XCTAssertEqual(SortType.daysDescending.name, "Days (Old-New)")
        XCTAssertEqual(SortType.category.name, "Category")
    }

    // MARK: - ID

    func testIDMatchesRawValue() {
        for sortType in SortType.allCases {
            XCTAssertEqual(sortType.id, sortType.rawValue)
        }
    }

    // MARK: - Alphabetical Ascending (A-Z)

    func testAlphabeticalAscending() {
        let apple = makeItem(name: "Apple", daysAgo: 0)
        let banana = makeItem(name: "Banana", daysAgo: 0)
        let cherry = makeItem(name: "Cherry", daysAgo: 0)

        XCTAssertTrue(SortType.alphabeticallyAscending.sort(itemOne: apple, itemTwo: banana))
        XCTAssertTrue(SortType.alphabeticallyAscending.sort(itemOne: banana, itemTwo: cherry))
        XCTAssertFalse(SortType.alphabeticallyAscending.sort(itemOne: cherry, itemTwo: apple))
    }

    func testAlphabeticalAscendingSameNameReturnsFalse() {
        let item1 = makeItem(name: "Same", daysAgo: 0)
        let item2 = makeItem(name: "Same", daysAgo: 0)
        XCTAssertFalse(SortType.alphabeticallyAscending.sort(itemOne: item1, itemTwo: item2))
    }

    // MARK: - Alphabetical Descending (Z-A)

    func testAlphabeticalDescending() {
        let apple = makeItem(name: "Apple", daysAgo: 0)
        let banana = makeItem(name: "Banana", daysAgo: 0)

        XCTAssertFalse(SortType.alphabeticallyDescending.sort(itemOne: apple, itemTwo: banana))
        XCTAssertTrue(SortType.alphabeticallyDescending.sort(itemOne: banana, itemTwo: apple))
    }

    // MARK: - Days Ascending (New to Old)

    func testDaysAscendingNewerFirst() {
        let newer = makeItem(name: "New", daysAgo: 1)
        let older = makeItem(name: "Old", daysAgo: 10)

        XCTAssertTrue(SortType.daysAscending.sort(itemOne: newer, itemTwo: older))
        XCTAssertFalse(SortType.daysAscending.sort(itemOne: older, itemTwo: newer))
    }

    func testDaysAscendingSameDaysReturnsFalse() {
        let item1 = makeItem(name: "A", daysAgo: 5)
        let item2 = makeItem(name: "B", daysAgo: 5)
        XCTAssertFalse(SortType.daysAscending.sort(itemOne: item1, itemTwo: item2))
    }

    // MARK: - Days Descending (Old to New)

    func testDaysDescendingOlderFirst() {
        let newer = makeItem(name: "New", daysAgo: 1)
        let older = makeItem(name: "Old", daysAgo: 10)

        XCTAssertFalse(SortType.daysDescending.sort(itemOne: newer, itemTwo: older))
        XCTAssertTrue(SortType.daysDescending.sort(itemOne: older, itemTwo: newer))
    }

    // MARK: - Category Sort

    func testCategorySort() {
        let workItem = makeItem(name: "A", daysAgo: 0, category: workCategory)
        let lifeItem = makeItem(name: "B", daysAgo: 0, category: lifeCategory)

        // Category sort uses > on category.name, so "Work" > "Life" = true
        let result = SortType.category.sort(itemOne: workItem, itemTwo: lifeItem)
        XCTAssertTrue(result)
    }

    // MARK: - Full Sort Integration

    func testSortingArrayAlphabetically() {
        let items = [
            makeItem(name: "Cherry", daysAgo: 0),
            makeItem(name: "Apple", daysAgo: 0),
            makeItem(name: "Banana", daysAgo: 0),
        ]

        let sorted = items.sorted { SortType.alphabeticallyAscending.sort(itemOne: $0, itemTwo: $1) }
        XCTAssertEqual(sorted.map(\.name), ["Apple", "Banana", "Cherry"])
    }

    func testSortingArrayByDaysDescending() {
        let items = [
            makeItem(name: "A", daysAgo: 1),
            makeItem(name: "B", daysAgo: 100),
            makeItem(name: "C", daysAgo: 50),
        ]

        let sorted = items.sorted { SortType.daysDescending.sort(itemOne: $0, itemTwo: $1) }
        XCTAssertEqual(sorted.map(\.name), ["B", "C", "A"])
    }
}
