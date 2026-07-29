@testable import DaysSince
import Foundation
import Testing

/// `CategoryManager` gets an injected store, so nothing here touches `.standard` —
/// but it fires analytics through the global `Analytics.sink`, hence the umbrella.
extension GlobalStateSuite {

    /// `@MainActor` because the manager wraps its mutations in `withAnimation` and
    /// publishes through `objectWillChange`.
    @Suite("CategoryManager")
    @MainActor
    struct CategoryManagerTests {

        private func makeManager(
            _ categories: [DaysSince.Category] = DaysSince.Category.builtInDefaults
        ) -> (CategoryManager, MockCategoryStore) {
            let store = MockCategoryStore(categories)
            return (CategoryManager(store: store), store)
        }

        // MARK: - Add

        @Test("a new category is appended with the next sort order")
        func addAssignsNextSortOrder() {
            let (manager, store) = makeManager()

            manager.addCategory(name: "Pets", emoji: "pawprint", color: .marioBlue)

            let added = store.categories.last
            #expect(store.categories.count == 5)
            #expect(added?.name == "Pets")
            #expect(added?.emoji == "pawprint")
            #expect(added?.color == .marioBlue)
            #expect(added?.sortOrder == 4)
            #expect(store.writeCount == 1)
        }

        @Test("the next sort order is one past the maximum, not the count")
        func addUsesMaxSortOrder() {
            let (manager, store) = makeManager([
                Fixtures.category(stableID: "a", name: "A", sortOrder: 7),
                Fixtures.category(stableID: "b", name: "B", sortOrder: 3),
            ])

            manager.addCategory(name: "C", emoji: "star", color: .life)

            #expect(store.categories.last?.sortOrder == 8)
        }

        @Test("adding to an empty list starts at zero")
        func addToEmptyStartsAtZero() {
            let (manager, store) = makeManager([])

            manager.addCategory(name: "First", emoji: "star", color: .life)

            #expect(store.categories.map(\.sortOrder) == [0])
        }

        @Test("a new category has a generated stable ID")
        func addGeneratesStableID() {
            let (manager, store) = makeManager([])

            manager.addCategory(name: "Pets", emoji: "pawprint", color: .life)

            let stableID = store.categories.first?.stableID
            #expect(stableID?.isEmpty == false)
            #expect(UUID(uuidString: stableID ?? "") != nil)
        }

        @Test("adding fires analytics with the emoji and color")
        func addFiresAnalytics() {
            let (manager, _) = makeManager()

            withAnalyticsSpy { spy in
                manager.addCategory(name: "Pets", emoji: "pawprint", color: .marioRed)

                #expect(spy.count(of: .addNewCategory) == 1)
                #expect(spy.parameters(of: .addNewCategory) == ["emoji": "pawprint", "color": CategoryColor.marioRed.id])
            }
        }

        // MARK: - Delete

        @Test("an empty category is deleted by index")
        func deleteByIndex() {
            let (manager, store) = makeManager()
            let removed = store.categories[1]

            manager.deleteCategory(at: 1, items: [])

            #expect(store.categories.count == 3)
            #expect(!store.categories.contains(removed))
            #expect(store.writeCount == 1)
        }

        @Test("an empty category is deleted by value")
        func deleteByValue() {
            let (manager, store) = makeManager()
            let removed = store.categories[2]

            manager.deleteCategory(category: removed, items: [])

            #expect(store.categories.count == 3)
            #expect(!store.categories.contains(removed))
        }

        @Test("deleting by index is blocked while an item references the category")
        func deleteByIndexBlockedWhenReferenced() {
            let (manager, store) = makeManager()
            let referenced = store.categories[0]

            manager.deleteCategory(at: 0, items: [Fixtures.item(category: referenced)])

            #expect(store.categories.count == 4)
            #expect(store.writeCount == 0)
        }

        @Test("deleting by value is blocked while an item references the category")
        func deleteByValueBlockedWhenReferenced() {
            let (manager, store) = makeManager()
            let referenced = store.categories[0]

            manager.deleteCategory(category: referenced, items: [Fixtures.item(category: referenced)])

            #expect(store.categories.count == 4)
            #expect(store.writeCount == 0)
        }

        @Test("an out-of-range index is ignored")
        func deleteOutOfRangeIsIgnored() {
            let (manager, store) = makeManager()

            manager.deleteCategory(at: 99, items: [])

            #expect(store.categories.count == 4)
            #expect(store.writeCount == 0)
        }

        @Test("deleting a category that is not stored is ignored")
        func deleteUnknownCategoryIsIgnored() {
            let (manager, store) = makeManager()

            manager.deleteCategory(category: Fixtures.category(stableID: "nope", name: "Nope"), items: [])

            #expect(store.categories.count == 4)
            #expect(store.writeCount == 0)
        }

        // MARK: - Update

        @Test("updating rewrites name, emoji and color in the store")
        func updateRewritesStoredCategory() {
            let (manager, store) = makeManager()
            let original = store.categories[0]
            var items: [DSItem] = []

            manager.updateCategory(category: original, name: "Career", emoji: "briefcase", color: .zeldaYellow, items: &items)

            let updated = store.categories[0]
            #expect(updated.stableID == original.stableID)
            #expect(updated.name == "Career")
            #expect(updated.emoji == "briefcase")
            #expect(updated.color == .zeldaYellow)
            #expect(updated.lastModified > original.lastModified)
        }

        @Test("updating propagates into every item in that category")
        func updatePropagatesToItems() {
            let (manager, store) = makeManager()
            let target = store.categories[0]
            let other = store.categories[1]
            var items = [
                Fixtures.item(name: "One", category: target),
                Fixtures.item(name: "Two", category: target),
                Fixtures.item(name: "Three", category: other),
            ]

            manager.updateCategory(category: target, name: "Career", emoji: "briefcase", color: .zeldaYellow, items: &items)

            #expect(items[0].category.name == "Career")
            #expect(items[0].category.emoji == "briefcase")
            #expect(items[0].category.color == .zeldaYellow)
            #expect(items[1].category.name == "Career")
            #expect(items[2].category.name == other.name)
        }

        @Test("updating an unknown category leaves everything alone")
        func updateUnknownCategoryIsIgnored() {
            let (manager, store) = makeManager()
            var items = [Fixtures.item(category: store.categories[0])]

            manager.updateCategory(
                category: Fixtures.category(stableID: "nope", name: "Nope"),
                name: "Career",
                emoji: "briefcase",
                color: .zeldaYellow,
                items: &items
            )

            #expect(store.categories == DaysSince.Category.builtInDefaults)
            #expect(store.writeCount == 0)
            #expect(items[0].category.name == "Work")
        }

        @Test("updating fires analytics with the new emoji and color")
        func updateFiresAnalytics() {
            let (manager, store) = makeManager()
            var items: [DSItem] = []

            withAnalyticsSpy { spy in
                manager.updateCategory(category: store.categories[0], name: "Career", emoji: "briefcase", color: .black, items: &items)

                #expect(spy.count(of: .updateCategory) == 1)
                #expect(spy.parameters(of: .updateCategory) == ["emoji": "briefcase", "color": CategoryColor.black.id])
            }
        }

        // MARK: - Move

        @Test("moving a category down reorders and reindexes sort orders")
        func moveDownReindexes() {
            let (manager, store) = makeManager()
            let dragged = store.categories[0]
            let destination = store.categories[2]

            manager.move(destinationCategory: destination, draggedCategory: dragged)

            #expect(store.categories.map(\.name) == ["Life", "Hobby", "Work", "Health"])
            #expect(store.categories.map(\.sortOrder) == [0, 1, 2, 3])
        }

        @Test("moving a category up reorders and reindexes sort orders")
        func moveUpReindexes() {
            let (manager, store) = makeManager()
            let dragged = store.categories[3]
            let destination = store.categories[1]

            manager.move(destinationCategory: destination, draggedCategory: dragged)

            #expect(store.categories.map(\.name) == ["Work", "Health", "Life", "Hobby"])
            #expect(store.categories.map(\.sortOrder) == [0, 1, 2, 3])
        }

        @Test("moving onto itself only reindexes")
        func moveOntoSelfOnlyReindexes() {
            let (manager, store) = makeManager([
                Fixtures.category(stableID: "a", name: "A", sortOrder: 5),
                Fixtures.category(stableID: "b", name: "B", sortOrder: 9),
            ])
            let same = store.categories[1]

            manager.move(destinationCategory: same, draggedCategory: same)

            #expect(store.categories.map(\.name) == ["A", "B"])
            #expect(store.categories.map(\.sortOrder) == [0, 1])
        }

        @Test("a nil dragged category still normalizes sort orders")
        func moveWithNilDraggedReindexes() {
            let (manager, store) = makeManager([
                Fixtures.category(stableID: "a", name: "A", sortOrder: 4),
                Fixtures.category(stableID: "b", name: "B", sortOrder: 4),
            ])

            manager.move(destinationCategory: store.categories[0], draggedCategory: nil)

            #expect(store.categories.map(\.sortOrder) == [0, 1])
        }

        // MARK: - Sync

        @Test("a mutation reaches iCloud through DataSyncManager")
        func mutationPushesToiCloud() throws {
            let store = MockCategoryStore()
            let kvs = MockKeyValueStore()
            let appGroup = IsolatedDefaults()
            let sync = DataSyncManager(appGroupDefaults: appGroup.defaults, iCloudStore: kvs, categoryStore: store)
            let manager = CategoryManager(store: store)
            manager.dataSyncManager = sync

            manager.addCategory(name: "Pets", emoji: "pawprint", color: .life)

            let pushed = try #require(kvs.decode([DaysSince.Category].self, forKey: DataSyncManager.categoriesKey))
            #expect(pushed.map(\.name) == ["Work", "Life", "Hobby", "Health", "Pets"])
            #expect(sync.categories.count == 5)
        }

        @Test("mutations work without a DataSyncManager attached")
        func mutationWithoutSyncManager() {
            let (manager, store) = makeManager()

            manager.addCategory(name: "Pets", emoji: "pawprint", color: .life)

            #expect(store.categories.count == 5)
        }
    }
}
