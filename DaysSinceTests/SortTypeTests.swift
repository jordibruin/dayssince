@testable import DaysSince
import Foundation
import Testing

@Suite("SortType")
struct SortTypeTests {
    let workCategory = Fixtures.category()
    let lifeCategory = Fixtures.category(
        stableID: DaysSince.Category.stableIDLife,
        name: "Life",
        emoji: "leaf",
        color: .life
    )

    /// `DSItem.daysAgo` is computed against `Date.now`, so items must still be
    /// built relative to today for the day-based sorts to mean anything.
    func makeItem(name: String, daysAgo: Int, category: DaysSince.Category? = nil) -> DSItem {
        let date = Calendar.current.date(byAdding: .day, value: -daysAgo, to: Date.now)!
        return Fixtures.item(
            name: name,
            category: category ?? workCategory,
            dateLastDone: date
        )
    }

    // MARK: - All Cases

    @Test("there are five sort types")
    func allCasesCount() {
        #expect(SortType.allCases.count == 5)
    }

    // MARK: - Names

    @Test("display names", arguments: [
        (SortType.alphabeticallyAscending, "Alphabetical (A-Z)"),
        (SortType.alphabeticallyDescending, "Alphabetical (Z-A)"),
        (SortType.daysAscending, "Days (New-Old)"),
        (SortType.daysDescending, "Days (Old-New)"),
        (SortType.category, "Category"),
    ])
    func sortTypeNames(sortType: SortType, expectedName: String) {
        #expect(sortType.name == expectedName)
    }

    // MARK: - ID

    @Test("id matches rawValue", arguments: SortType.allCases)
    func idMatchesRawValue(sortType: SortType) {
        #expect(sortType.id == sortType.rawValue)
    }

    // MARK: - Alphabetical Ascending (A-Z)

    @Test("alphabetical ascending compares names", arguments: [
        (("Apple", "Banana"), true),
        (("Banana", "Cherry"), true),
        (("Cherry", "Apple"), false),
        (("Same", "Same"), false), // equal names must not report "less than"
    ])
    func alphabeticalAscending(names: (String, String), expected: Bool) {
        let itemOne = makeItem(name: names.0, daysAgo: 0)
        let itemTwo = makeItem(name: names.1, daysAgo: 0)
        #expect(SortType.alphabeticallyAscending.sort(itemOne: itemOne, itemTwo: itemTwo) == expected)
    }

    // MARK: - Alphabetical Descending (Z-A)

    @Test("alphabetical descending compares names", arguments: [
        (("Apple", "Banana"), false),
        (("Banana", "Apple"), true),
    ])
    func alphabeticalDescending(names: (String, String), expected: Bool) {
        let itemOne = makeItem(name: names.0, daysAgo: 0)
        let itemTwo = makeItem(name: names.1, daysAgo: 0)
        #expect(SortType.alphabeticallyDescending.sort(itemOne: itemOne, itemTwo: itemTwo) == expected)
    }

    // MARK: - Days Ascending (New to Old)

    @Test("days ascending puts newer first", arguments: [
        ((1, 10), true),
        ((10, 1), false),
        ((5, 5), false), // equal day counts must not report "less than"
    ])
    func daysAscending(daysAgo: (Int, Int), expected: Bool) {
        let itemOne = makeItem(name: "A", daysAgo: daysAgo.0)
        let itemTwo = makeItem(name: "B", daysAgo: daysAgo.1)
        #expect(SortType.daysAscending.sort(itemOne: itemOne, itemTwo: itemTwo) == expected)
    }

    // MARK: - Days Descending (Old to New)

    @Test("days descending puts older first", arguments: [
        ((1, 10), false),
        ((10, 1), true),
    ])
    func daysDescending(daysAgo: (Int, Int), expected: Bool) {
        let itemOne = makeItem(name: "A", daysAgo: daysAgo.0)
        let itemTwo = makeItem(name: "B", daysAgo: daysAgo.1)
        #expect(SortType.daysDescending.sort(itemOne: itemOne, itemTwo: itemTwo) == expected)
    }

    // MARK: - Category Sort

    @Test("category sort compares category names descending")
    func categorySort() {
        let workItem = makeItem(name: "A", daysAgo: 0, category: workCategory)
        let lifeItem = makeItem(name: "B", daysAgo: 0, category: lifeCategory)

        // Category sort uses > on category.name, so "Work" > "Life" = true
        let result = SortType.category.sort(itemOne: workItem, itemTwo: lifeItem)
        #expect(result)
    }

    // MARK: - Full Sort Integration

    @Test("sorting an array alphabetically")
    func sortingArrayAlphabetically() {
        let items = [
            makeItem(name: "Cherry", daysAgo: 0),
            makeItem(name: "Apple", daysAgo: 0),
            makeItem(name: "Banana", daysAgo: 0),
        ]

        let sorted = items.sorted { SortType.alphabeticallyAscending.sort(itemOne: $0, itemTwo: $1) }
        #expect(sorted.map(\.name) == ["Apple", "Banana", "Cherry"])
    }

    @Test("sorting an array by days descending")
    func sortingArrayByDaysDescending() {
        let items = [
            makeItem(name: "A", daysAgo: 1),
            makeItem(name: "B", daysAgo: 100),
            makeItem(name: "C", daysAgo: 50),
        ]

        let sorted = items.sorted { SortType.daysDescending.sort(itemOne: $0, itemTwo: $1) }
        #expect(sorted.map(\.name) == ["B", "C", "A"])
    }
}
