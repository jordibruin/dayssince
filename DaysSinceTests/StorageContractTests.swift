@testable import DaysSince
import Defaults
import Foundation
import Testing

/// Pins the App Group storage format. Items are written by `@AppStorage` through
/// `RawRepresentable`, which stores arrays as JSON **strings** — reading them back with
/// `.data(forKey:)` returns nil and silently produces an empty list. That is the
/// data-loss trap this suite guards.
///
/// Nested in the umbrella because `DataSyncManager` fires analytics.
extension GlobalStateSuite {

    @Suite("App Group storage contract")
    struct StorageContractTests {

        private func makeManager(
            _ defaults: UserDefaults,
            reloader: SpyWidgetReloader = SpyWidgetReloader()
        ) -> DataSyncManager {
            DataSyncManager(
                appGroupDefaults: defaults,
                iCloudStore: MockKeyValueStore(),
                categoryStore: MockCategoryStore(),
                widgetReloader: reloader
            )
        }

        @Test("items written by the app are stored as a JSON string, not Data")
        func writesJSONString() {
            let suite = IsolatedDefaults()
            let manager = makeManager(suite.defaults)

            manager.saveItems([Fixtures.item(name: "Dentist")])

            #expect(suite.defaults.string(forKey: DataSyncManager.itemsKey) != nil)
            #expect(suite.defaults.data(forKey: DataSyncManager.itemsKey) == nil)
        }

        @Test("a saved item round trips through the App Group")
        func roundTrip() throws {
            let suite = IsolatedDefaults()
            let manager = makeManager(suite.defaults)
            let item = Fixtures.item(name: "Dentist")

            manager.saveItems([item])
            let loaded = DataSyncManager.loadItems(from: suite.defaults)

            let first = try #require(loaded.first)
            #expect(loaded.count == 1)
            #expect(first.id == item.id)
            #expect(first.name == "Dentist")
            #expect(first.category.stableID == item.category.stableID)
        }

        @Test("a fresh manager picks up items already in the App Group")
        func initialLoadReadsExistingItems() throws {
            let suite = IsolatedDefaults()
            let json = try String(data: JSONEncoder().encode([Fixtures.item(name: "Haircut")]), encoding: .utf8)
            suite.defaults.set(json, forKey: DataSyncManager.itemsKey)

            let manager = makeManager(suite.defaults)

            #expect(manager.items.map(\.name) == ["Haircut"])
        }

        /// The canary for the documented trap: a value written as `Data` is invisible to
        /// the `@AppStorage` string path. `loadItems` keeps a Data fallback for its own
        /// historical writes, so it still reads — but `.string(forKey:)` does not.
        @Test("a value written as Data is not readable through the string path")
        func dataWriteIsNotVisibleAsString() throws {
            let suite = IsolatedDefaults()
            let data = try JSONEncoder().encode([Fixtures.item(name: "Legacy")])
            suite.defaults.set(data, forKey: DataSyncManager.itemsKey)

            #expect(suite.defaults.string(forKey: DataSyncManager.itemsKey) == nil)
            #expect(DataSyncManager.loadItems(from: suite.defaults).map(\.name) == ["Legacy"])
        }

        @Test("an empty save clears the stored items")
        func emptySaveClears() {
            let suite = IsolatedDefaults()
            let manager = makeManager(suite.defaults)

            manager.saveItems([Fixtures.item(name: "Dentist")])
            manager.saveItems([])

            #expect(DataSyncManager.loadItems(from: suite.defaults).isEmpty)
        }

        @Test("saving reloads the widget timelines")
        func saveReloadsWidgets() {
            let suite = IsolatedDefaults()
            let reloader = SpyWidgetReloader()
            let manager = makeManager(suite.defaults, reloader: reloader)

            manager.saveItems([Fixtures.item()])

            #expect(reloader.reloadCount == 1)
        }

        @Test(
            "unreadable stored values decode to an empty list rather than crashing",
            arguments: ["", "not json", "{}", "[{\"id\":\"nope\"}]", "[1, 2, 3]"]
        )
        func garbageDecodesToEmpty(stored: String) {
            let suite = IsolatedDefaults()
            suite.defaults.set(stored, forKey: DataSyncManager.itemsKey)

            #expect(DataSyncManager.loadItems(from: suite.defaults).isEmpty)
        }

        @Test("a missing key decodes to an empty list")
        func missingKeyDecodesToEmpty() {
            #expect(DataSyncManager.loadItems(from: IsolatedDefaults().defaults).isEmpty)
        }

        @Test("invalid UTF-8 bytes decode to an empty list")
        func invalidUTF8DecodesToEmpty() {
            let suite = IsolatedDefaults()
            suite.defaults.set(Data([0xFF, 0xFE, 0xFD]), forKey: DataSyncManager.itemsKey)

            #expect(DataSyncManager.loadItems(from: suite.defaults).isEmpty)
        }

        @Test("one corrupt element discards the whole list")
        func partiallyCorruptListDecodesToEmpty() throws {
            let suite = IsolatedDefaults()
            let data = try JSONEncoder().encode([Fixtures.item(name: "Good")])
            var array = try JSONSerialization.jsonObject(with: data) as! [[String: Any]]
            array.append(["id": "not-a-uuid"])
            let json = try String(data: JSONSerialization.data(withJSONObject: array), encoding: .utf8)
            suite.defaults.set(json, forKey: DataSyncManager.itemsKey)

            #expect(DataSyncManager.loadItems(from: suite.defaults).isEmpty)
        }

        @Test("categories round trip through a Defaults suite")
        func categoriesRoundTripThroughDefaults() {
            let suite = IsolatedDefaults()
            let store = DefaultsCategoryStore(suite: suite.defaults)

            #expect(store.categories == DaysSince.Category.builtInDefaults)

            let custom = Fixtures.category(stableID: "pets", name: "Pets", emoji: "pawprint", color: .marioBlue, sortOrder: 9)
            store.categories = DaysSince.Category.builtInDefaults + [custom]

            let reread = DefaultsCategoryStore(suite: suite.defaults).categories
            #expect(reread.count == 5)
            #expect(reread.last?.stableID == "pets")
            #expect(reread.last?.name == "Pets")
            #expect(reread.last?.emoji == "pawprint")
            #expect(reread.last?.color == .marioBlue)
            #expect(reread.last?.sortOrder == 9)
        }

        @Test("an injected category store never touches the standard suite")
        func injectedStoreIsIsolated() {
            let suite = IsolatedDefaults()
            let store = DefaultsCategoryStore(suite: suite.defaults)
            let globalBefore = Defaults[.categories]

            store.categories = [Fixtures.category(stableID: "only", name: "Only")]

            #expect(Defaults[.categories] == globalBefore)
            #expect(store.categories.map(\.stableID) == ["only"])
        }
    }
}
