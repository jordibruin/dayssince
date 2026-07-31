@testable import DaysSince
import Defaults
import Foundation
import Testing

/// `DataSyncManager` reads and writes the global `Defaults[.categories]` (i.e.
/// `UserDefaults.standard`) and fires analytics through the global `Analytics.sink`,
/// so it lives in the serialized umbrella. Each test starts from the built-in category
/// defaults and the original value is restored afterwards.
extension GlobalStateSuite {

    @Suite("DataSyncManager sync and merge")
    final class DataSyncManagerMergeTests {

        private let fixedDate = Fixtures.referenceDate
        private let olderDate = Fixtures.olderDate
        private let newerDate = Fixtures.newerDate

        private let savedCategories: [DaysSince.Category]

        /// Retains the per-test suites so their `deinit` deletes the backing plists.
        private var isolatedSuites: [IsolatedDefaults] = []

        init() {
            savedCategories = Defaults[.categories]
            Defaults.reset(.categories)
        }

        deinit {
            Defaults[.categories] = savedCategories
        }

        // MARK: - Helpers

        private func makeItem(id: UUID = UUID(), name: String, lastModified: Date? = nil) -> DSItem {
            Fixtures.item(
                id: id,
                name: name,
                category: Fixtures.category(name: "Work"),
                dateLastDone: fixedDate,
                lastModified: lastModified ?? fixedDate
            )
        }

        private func makeCategory(
            stableID: String,
            name: String,
            color: CategoryColor = .work,
            sortOrder: Int = 0,
            lastModified: Date? = nil
        ) -> DaysSince.Category {
            Fixtures.category(
                stableID: stableID,
                name: name,
                color: color,
                sortOrder: sortOrder,
                lastModified: lastModified ?? fixedDate
            )
        }

        /// A fresh App Group stand-in, cleaned up when this test instance is released.
        private func makeAppGroupDefaults() -> UserDefaults {
            let isolated = IsolatedDefaults()
            isolatedSuites.append(isolated)
            return isolated.defaults
        }

        private func writeLocalItems(_ items: [DSItem], to defaults: UserDefaults) {
            // Items are stored as a JSON *string*, not Data — see Array+Extensions.
            let json = String(data: try! JSONEncoder().encode(items), encoding: .utf8)!
            defaults.set(json, forKey: DataSyncManager.itemsKey)
        }

        private func makeManager(
            localItems: [DSItem] = [],
            remoteItems: [DSItem] = [],
            remoteCategories: [DaysSince.Category] = []
        ) -> (manager: DataSyncManager, store: MockKeyValueStore, defaults: UserDefaults) {
            let store = MockKeyValueStore()
            let appGroupDefaults = makeAppGroupDefaults()

            if !remoteItems.isEmpty {
                store.encode(remoteItems, forKey: DataSyncManager.itemsKey)
            }
            if !remoteCategories.isEmpty {
                store.encode(remoteCategories, forKey: DataSyncManager.categoriesKey)
            }
            if !localItems.isEmpty {
                writeLocalItems(localItems, to: appGroupDefaults)
            }

            let manager = DataSyncManager(appGroupDefaults: appGroupDefaults, iCloudStore: store)
            return (manager, store, appGroupDefaults)
        }

        private func iCloudItems(in store: MockKeyValueStore) throws -> [DSItem] {
            let data = try #require(store.data(forKey: DataSyncManager.itemsKey))
            return try JSONDecoder().decode([DSItem].self, from: data)
        }

        // MARK: - 1. Existing User Migration

        @Test("First device pushes local data to an empty iCloud")
        func migrationFirstDevicePushesToEmptyiCloud() {
            let localItems = [makeItem(name: "My Event"), makeItem(name: "Another Event")]
            let (manager, store, _) = makeManager(localItems: localItems)

            let result = manager.performMigration()

            #expect(result.items == 2)
            #expect(store.storage[DataSyncManager.itemsKey] != nil, "Items should be pushed to iCloud")
            #expect(store.storage[DataSyncManager.categoriesKey] != nil, "Categories should be pushed to iCloud")
        }

        @Test("Second device merges its local data with what iCloud already has")
        func migrationSecondDeviceMergesWithiCloud() {
            // Device A already migrated: iCloud has {A1, A2}
            let remoteItems = [makeItem(name: "Event A1"), makeItem(name: "Event A2")]
            // Device B has local items {B1, B2}
            let localItems = [makeItem(name: "Event B1"), makeItem(name: "Event B2")]

            let (manager, _, _) = makeManager(localItems: localItems, remoteItems: remoteItems)
            let result = manager.performMigration()

            #expect(result.items == 4)
            let names = Set(manager.items.map(\.name))
            #expect(names.contains("Event A1"))
            #expect(names.contains("Event A2"))
            #expect(names.contains("Event B1"))
            #expect(names.contains("Event B2"))
        }

        // MARK: - 2. New User (Fresh Install)

        @Test("Fresh install with empty iCloud yields no items and does not crash")
        func freshInstallWithEmptyiCloud() {
            let (manager, _, _) = makeManager()
            manager.startSync()

            #expect(manager.items.isEmpty)
        }

        // MARK: - 3. Two-Device Sync (CRUD)

        @Test("Saving items dual-writes to the App Group and iCloud")
        func saveItemsWritesToBothLocalAndiCloud() throws {
            let (manager, store, appGroupDefaults) = makeManager()

            let newItem = makeItem(name: "New Event")
            manager.saveItems([newItem])

            #expect(manager.items.count == 1)
            #expect(manager.items.first?.name == "New Event")

            let remote = try iCloudItems(in: store)
            #expect(remote.count == 1)
            #expect(remote.first?.name == "New Event")

            let local = DataSyncManager.loadItems(from: appGroupDefaults)
            #expect(local.count == 1)
            #expect(local.first?.name == "New Event")
        }

        @Test("Editing an item propagates to iCloud")
        func editItemPropagates() throws {
            let itemID = UUID()
            let original = makeItem(id: itemID, name: "Original", lastModified: olderDate)
            let (manager, store, _) = makeManager(localItems: [original], remoteItems: [original])

            var edited = original
            edited.name = "Edited"
            edited.lastModified = newerDate
            manager.saveItems([edited])

            let remote = try iCloudItems(in: store)
            #expect(remote.count == 1)
            #expect(remote.first?.name == "Edited")
        }

        @Test("Deleting an item propagates to iCloud")
        func deleteItemPropagates() throws {
            let item1 = makeItem(name: "Keep")
            let item2 = makeItem(name: "Delete")
            let (manager, store, _) = makeManager(localItems: [item1, item2])

            manager.saveItems([item1])

            let remote = try iCloudItems(in: store)
            #expect(remote.count == 1)
            #expect(remote.first?.name == "Keep")
        }

        // MARK: - 4. Delete and Reinstall (Restore from iCloud)

        @Test("Fresh install restores items and categories from iCloud")
        func freshInstallRestoresFromiCloud() {
            let remoteItems = [makeItem(name: "Restored Event")]
            let remoteCategories = [makeCategory(stableID: "custom-travel", name: "Travel")]

            let (manager, _, _) = makeManager(remoteItems: remoteItems, remoteCategories: remoteCategories)

            // Local is empty (fresh install) — startSync should restore
            manager.startSync()

            #expect(manager.items.count == 1)
            #expect(manager.items.first?.name == "Restored Event")
            #expect(Set(manager.categories.map(\.stableID)).contains("custom-travel"))
        }

        // MARK: - 5. Conflict / Simultaneous Edits

        @Test("Conflict on the same item keeps the newer local version")
        func conflictKeepsNewerLocalItem() {
            let sharedID = UUID()
            let remoteItems = [makeItem(id: sharedID, name: "Remote Version", lastModified: olderDate)]
            let localItems = [makeItem(id: sharedID, name: "Local Version", lastModified: newerDate)]

            let (manager, _, _) = makeManager(localItems: localItems, remoteItems: remoteItems)
            manager.performMigration()

            #expect(manager.items.count == 1)
            #expect(manager.items.first?.name == "Local Version")
        }

        @Test("Conflict on the same item keeps the newer remote version")
        func conflictKeepsNewerRemoteItem() {
            let sharedID = UUID()
            let remoteItems = [makeItem(id: sharedID, name: "Remote Version", lastModified: newerDate)]
            let localItems = [makeItem(id: sharedID, name: "Local Version", lastModified: olderDate)]

            let (manager, _, _) = makeManager(localItems: localItems, remoteItems: remoteItems)
            manager.performMigration()

            #expect(manager.items.count == 1)
            #expect(manager.items.first?.name == "Remote Version")
        }

        @Test("Mixed merge keeps both unique sides and the newer conflicting item")
        func conflictMixedMerge() {
            let sharedID = UUID()
            let localOnly = makeItem(name: "Local Only")
            let remoteOnly = makeItem(name: "Remote Only")
            let localVersion = makeItem(id: sharedID, name: "Shared - Local Edit", lastModified: newerDate)
            let remoteVersion = makeItem(id: sharedID, name: "Shared - Remote Edit", lastModified: olderDate)

            let (manager, _, _) = makeManager(
                localItems: [localOnly, localVersion],
                remoteItems: [remoteOnly, remoteVersion]
            )
            manager.startSync()

            #expect(manager.items.count == 3)
            let names = Set(manager.items.map(\.name))
            #expect(names.contains("Local Only"))
            #expect(names.contains("Remote Only"))
            #expect(names.contains("Shared - Local Edit"), "Newer local version should win")
        }

        // MARK: - 6. Storage Limit Warning

        @Test("iCloud usage is measured once items are saved")
        func storageUsageIsMeasuredAfterSave() {
            let (manager, _, _) = makeManager()

            let items = (0 ..< 5).map { makeItem(name: "Event \($0)") }
            manager.saveItems(items)

            #expect(manager.iCloudUsageBytes > 0)
        }

        @Test("iCloud usage grows with the amount of data")
        func storageUsageBytesReflectsData() {
            let (manager, _, _) = makeManager()

            let emptyUsage = manager.iCloudUsageBytes

            manager.items = (0 ..< 10).map {
                makeItem(name: "Event \($0) with a longer name to take up space")
            }

            #expect(manager.iCloudUsageBytes > emptyUsage)
        }

        // MARK: - 7. Safety Guard

        @Test("Empty remote never wipes non-empty local items")
        func safetyGuardNeverOverwritesLocalWithEmptyRemote() {
            let localItems = [makeItem(name: "Important Local Event")]
            let (manager, _, _) = makeManager(localItems: localItems)

            // iCloud is empty, local has data
            manager.startSync()

            #expect(manager.items.count == 1)
            #expect(manager.items.first?.name == "Important Local Event")
        }

        // MARK: - 8. Category Merge

        @Test("Category merge unions local and remote by stableID")
        func categoryMergeUnionsByStableID() {
            let remoteCategories = [
                makeCategory(stableID: "work", name: "Work"),
                makeCategory(stableID: "custom-a", name: "Travel"),
            ]
            let (manager, _, _) = makeManager(
                localItems: [makeItem(name: "Dummy")],
                remoteCategories: remoteCategories
            )

            manager.performMigration()

            let stableIDs = Set(manager.categories.map(\.stableID))
            #expect(stableIDs.contains("work"))
            #expect(stableIDs.contains("custom-a"), "Remote-only category should be merged in")
        }

        @Test("For a duplicate stableID the newer remote category wins")
        func categoryMergeNewerRemoteWins() {
            Defaults[.categories] = [
                makeCategory(stableID: "work", name: "Work Local", color: .work, lastModified: olderDate),
            ]
            let remoteCategories = [
                makeCategory(stableID: "work", name: "Work Remote", color: .life, lastModified: newerDate),
            ]
            let (manager, _, _) = makeManager(
                localItems: [makeItem(name: "Dummy")],
                remoteCategories: remoteCategories
            )

            manager.performMigration()

            let workCategory = manager.categories.first { $0.stableID == "work" }
            #expect(workCategory != nil)
            #expect(workCategory?.name == "Work Remote")
            #expect(workCategory?.color == .life)
        }

        @Test("For a duplicate stableID the newer local category wins")
        func categoryMergeLocalWinsWhenNewer() {
            Defaults[.categories] = [
                makeCategory(stableID: "work", name: "Work Local", color: .work, lastModified: newerDate),
            ]
            let remoteCategories = [
                makeCategory(stableID: "work", name: "Work Remote", color: .life, lastModified: olderDate),
            ]
            let (manager, _, _) = makeManager(
                localItems: [makeItem(name: "Dummy")],
                remoteCategories: remoteCategories
            )

            manager.performMigration()

            let workCategory = manager.categories.first { $0.stableID == "work" }
            #expect(workCategory != nil)
            #expect(workCategory?.name == "Work Local")
        }

        @Test("Merged categories come back ordered by sortOrder")
        func categoryMergePreservesSortOrder() {
            Defaults[.categories] = [
                makeCategory(stableID: "health", name: "Health", sortOrder: 0),
                makeCategory(stableID: "work", name: "Work", sortOrder: 1),
                makeCategory(stableID: "life", name: "Life", sortOrder: 2),
            ]
            let remoteCategories = [
                makeCategory(stableID: "travel", name: "Travel", color: .life, sortOrder: 10),
            ]
            let (manager, _, _) = makeManager(
                localItems: [makeItem(name: "Dummy")],
                remoteCategories: remoteCategories
            )

            manager.performMigration()

            #expect(manager.categories.map(\.stableID) == ["health", "work", "life", "travel"])
        }

        // MARK: - 9. Sort Order Migration

        @Test("Pre-sortOrder data gets sequential sort orders assigned on init")
        func assignSequentialSortOrdersMigration() {
            // Simulate pre-sortOrder data: every category has sortOrder 0
            Defaults[.categories] = [
                makeCategory(stableID: "work", name: "Work", sortOrder: 0),
                makeCategory(stableID: "life", name: "Life", sortOrder: 0),
                makeCategory(stableID: "hobby", name: "Hobby", sortOrder: 0),
            ]

            let manager = DataSyncManager(
                appGroupDefaults: makeAppGroupDefaults(),
                iCloudStore: MockKeyValueStore()
            )

            #expect(manager.categories.map(\.sortOrder) == [0, 1, 2])
        }

        @Test("Distinct sort orders are left alone on init")
        func sortOrderNotReassignedWhenAlreadyDistinct() {
            Defaults[.categories] = [
                makeCategory(stableID: "work", name: "Work", sortOrder: 5),
                makeCategory(stableID: "life", name: "Life", sortOrder: 10),
                makeCategory(stableID: "hobby", name: "Hobby", sortOrder: 15),
            ]

            let manager = DataSyncManager(
                appGroupDefaults: makeAppGroupDefaults(),
                iCloudStore: MockKeyValueStore()
            )

            #expect(manager.categories.map(\.sortOrder) == [5, 10, 15])
        }

        // MARK: - 10. StableID Reconciliation

        /// Builds a manager whose local store holds `items` and whose canonical category
        /// list is `categories`, mirroring the pre-stableID upgrade path.
        private func makeReconcilingManager(
            items: [DSItem],
            categories: [DaysSince.Category]
        ) -> (manager: DataSyncManager, defaults: UserDefaults) {
            let appGroupDefaults = makeAppGroupDefaults()
            writeLocalItems(items, to: appGroupDefaults)
            Defaults[.categories] = categories

            // init() runs reconcileCategoryStableIDs
            let manager = DataSyncManager(appGroupDefaults: appGroupDefaults, iCloudStore: MockKeyValueStore())
            return (manager, appGroupDefaults)
        }

        @Test("A custom category's orphaned stableID is reconciled to the canonical one")
        func reconcileFixesMismatchedCustomCategoryStableID() {
            let canonicalStableID = "canonical-travel-id"
            let travel = makeCategory(stableID: canonicalStableID, name: "Travel", color: .life)
            let orphaned = makeCategory(stableID: "random-uuid-from-decoder", name: "Travel", color: .life)

            let item = Fixtures.item(name: "Trip to Paris", category: orphaned, dateLastDone: fixedDate)
            let (manager, _) = makeReconcilingManager(items: [item], categories: [travel])

            #expect(manager.items.count == 1)
            #expect(manager.items.first?.category.stableID == canonicalStableID)
            #expect(manager.items.first?.name == "Trip to Paris")
        }

        @Test("Built-in categories are left untouched by reconciliation")
        func reconcileDoesNotTouchBuiltInCategories() {
            let work = makeCategory(stableID: DaysSince.Category.stableIDWork, name: "Work")
            let item = Fixtures.item(name: "Meeting", category: work, dateLastDone: fixedDate)

            let (manager, _) = makeReconcilingManager(items: [item], categories: [work])

            #expect(manager.items.first?.category.stableID == DaysSince.Category.stableIDWork)
        }

        @Test("Already-matching items are left untouched by reconciliation")
        func reconcileDoesNotTouchAlreadyMatchingItems() {
            let stableID = "my-custom-id"
            let cooking = makeCategory(stableID: stableID, name: "Cooking", color: .hobbies)
            let item = Fixtures.item(name: "Made pasta", category: cooking, dateLastDone: fixedDate)

            let (manager, _) = makeReconcilingManager(items: [item], categories: [cooking])

            #expect(manager.items.first?.category.stableID == stableID)
        }

        @Test("Every item in the same custom category is reconciled")
        func reconcileFixesMultipleItemsInSameCustomCategory() {
            let canonicalStableID = "canonical-fitness"
            let fitness = makeCategory(stableID: canonicalStableID, name: "Fitness", color: .health)

            // Each item carries a different orphaned stableID, as independent decoder runs produce
            let items = (0 ..< 3).map { index in
                Fixtures.item(
                    name: "Workout \(index)",
                    category: makeCategory(stableID: "orphan-\(index)", name: "Fitness", color: .health),
                    dateLastDone: fixedDate
                )
            }

            let (manager, _) = makeReconcilingManager(items: items, categories: [fitness])

            for item in manager.items {
                #expect(
                    item.category.stableID == canonicalStableID,
                    "Item '\(item.name)' should be reconciled"
                )
            }
        }

        @Test("Duplicate category names are disambiguated by color")
        func reconcileUsesExactMatchForDuplicateCategoryNames() {
            let redTravel = makeCategory(stableID: "travel-red", name: "Travel", color: .marioRed)
            let blueTravel = makeCategory(stableID: "travel-blue", name: "Travel", color: .marioBlue)

            // Item belongs to the blue variant
            let item = Fixtures.item(
                name: "Trip",
                category: makeCategory(stableID: "orphan-id", name: "Travel", color: .marioBlue),
                dateLastDone: fixedDate
            )

            let (manager, _) = makeReconcilingManager(items: [item], categories: [redTravel, blueTravel])

            #expect(manager.items.first?.category.stableID == "travel-blue")
        }

        @Test("Fully ambiguous categories are skipped rather than guessed")
        func reconcileSkipsFullyAmbiguousCategories() {
            // Identical name, emoji and color — there is no safe choice
            let travelA = makeCategory(stableID: "travel-a", name: "Travel", color: .life)
            let travelB = makeCategory(stableID: "travel-b", name: "Travel", color: .life)

            let orphanedStableID = "orphan-id"
            let item = Fixtures.item(
                name: "Trip",
                category: makeCategory(stableID: orphanedStableID, name: "Travel", color: .life),
                dateLastDone: fixedDate
            )

            let (manager, _) = makeReconcilingManager(items: [item], categories: [travelA, travelB])

            #expect(manager.items.first?.category.stableID == orphanedStableID)
        }

        @Test("Reconciled items are written back to the App Group")
        func reconcilePersistedToAppGroup() {
            let canonicalStableID = "canonical-cooking"
            let cooking = makeCategory(stableID: canonicalStableID, name: "Cooking", color: .hobbies)
            let item = Fixtures.item(
                name: "Made soup",
                category: makeCategory(stableID: "orphan", name: "Cooking", color: .hobbies),
                dateLastDone: fixedDate
            )

            let (_, appGroupDefaults) = makeReconcilingManager(items: [item], categories: [cooking])

            let reloaded = DataSyncManager.loadItems(from: appGroupDefaults)
            #expect(reloaded.first?.category.stableID == canonicalStableID)
        }

        // MARK: - 11. startSync Merge

        @Test("startSync merges local and remote instead of overwriting")
        func startSyncMergesInsteadOfOverwriting() {
            let remoteItems = [makeItem(name: "Device A Event")]
            let localItems = [makeItem(name: "Device B Event")]

            let (manager, _, _) = makeManager(localItems: localItems, remoteItems: remoteItems)
            manager.startSync()

            #expect(manager.items.count == 2)
            let names = Set(manager.items.map(\.name))
            #expect(names.contains("Device A Event"))
            #expect(names.contains("Device B Event"))
        }

        @Test("startSync pushes the merged result back to iCloud")
        func startSyncPushesMergedDataToiCloud() throws {
            let remoteItems = [makeItem(name: "Device A Event")]
            let localItems = [makeItem(name: "Device B Event")]

            let (manager, store, _) = makeManager(localItems: localItems, remoteItems: remoteItems)
            manager.startSync()

            #expect(try iCloudItems(in: store).count == 2)
        }
    }

}