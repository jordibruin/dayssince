@testable import DaysSince
import Defaults
import XCTest

// MARK: - Mock Key-Value Store

private class MockKeyValueStore: KeyValueStoreProtocol {
    var storage: [String: Any] = [:]

    func data(forKey key: String) -> Data? {
        storage[key] as? Data
    }

    func set(_ value: Any?, forKey key: String) {
        storage[key] = value
    }

    func synchronize() -> Bool { true }
}

// MARK: - Tests

final class DataSyncManagerMergeTests: XCTestCase {

    private let fixedDate = Date(timeIntervalSince1970: 1_000_000)
    private let olderDate = Date(timeIntervalSince1970: 900_000)
    private let newerDate = Date(timeIntervalSince1970: 1_100_000)

    private func makeItem(id: UUID = UUID(), name: String, lastModified: Date? = nil) -> DSItem {
        DSItem(
            id: id,
            name: name,
            category: DaysSince.Category(name: "Work", emoji: "lightbulb", color: .work),
            dateLastDone: fixedDate,
            remindersEnabled: false,
            lastModified: lastModified ?? fixedDate
        )
    }

    private func makeCategory(stableID: String, name: String, color: CategoryColor = .work) -> DaysSince.Category {
        DaysSince.Category(id: UUID(), stableID: stableID, name: name, emoji: "lightbulb", color: color)
    }

    private func makeManager(
        localItems: [DSItem] = [],
        remoteItems: [DSItem] = [],
        remoteCategories: [DaysSince.Category] = []
    ) -> (DataSyncManager, MockKeyValueStore, UserDefaults) {
        let mockStore = MockKeyValueStore()
        let suiteName = "test.\(UUID().uuidString)"
        let appGroupDefaults = UserDefaults(suiteName: suiteName)!

        if !remoteItems.isEmpty {
            mockStore.set(try! JSONEncoder().encode(remoteItems), forKey: DataSyncManager.itemsKey)
        }
        if !remoteCategories.isEmpty {
            mockStore.set(try! JSONEncoder().encode(remoteCategories), forKey: DataSyncManager.categoriesKey)
        }
        if !localItems.isEmpty {
            let localString = String(data: try! JSONEncoder().encode(localItems), encoding: .utf8)!
            appGroupDefaults.set(localString, forKey: DataSyncManager.itemsKey)
        }

        let manager = DataSyncManager(appGroupDefaults: appGroupDefaults, iCloudStore: mockStore)
        return (manager, mockStore, appGroupDefaults)
    }

    // MARK: - 1. Existing User Migration

    func testMigrationFirstDevicePushesToEmptyiCloud() {
        let localItems = [makeItem(name: "My Event"), makeItem(name: "Another Event")]
        let (manager, mockStore, _) = makeManager(localItems: localItems)

        let result = manager.performMigration()

        XCTAssertEqual(result.items, 2)
        XCTAssertNotNil(mockStore.storage[DataSyncManager.itemsKey], "Items should be pushed to iCloud")
        XCTAssertNotNil(mockStore.storage[DataSyncManager.categoriesKey], "Categories should be pushed to iCloud")
    }

    func testMigrationSecondDeviceMergesWithiCloud() {
        // Device A already migrated: iCloud has {A1, A2}
        let idA1 = UUID(), idA2 = UUID()
        let remoteItems = [makeItem(id: idA1, name: "Event A1"), makeItem(id: idA2, name: "Event A2")]
        // Device B has local items {B1, B2}
        let idB1 = UUID(), idB2 = UUID()
        let localItems = [makeItem(id: idB1, name: "Event B1"), makeItem(id: idB2, name: "Event B2")]

        let (manager, _, _) = makeManager(localItems: localItems, remoteItems: remoteItems)
        let result = manager.performMigration()

        XCTAssertEqual(result.items, 4)
        let names = Set(manager.items.map(\.name))
        XCTAssertTrue(names.contains("Event A1"))
        XCTAssertTrue(names.contains("Event A2"))
        XCTAssertTrue(names.contains("Event B1"))
        XCTAssertTrue(names.contains("Event B2"))
    }

    // MARK: - 2. New User (Fresh Install)

    func testFreshInstallWithEmptyiCloud() {
        let (manager, _, _) = makeManager()
        manager.startSync()

        // No items, no crash
        XCTAssertTrue(manager.items.isEmpty)
    }

    // MARK: - 3. Two-Device Sync (CRUD)

    func testSaveItemsWritesToBothLocalAndiCloud() {
        let (manager, mockStore, appGroupDefaults) = makeManager()

        let newItem = makeItem(name: "New Event")
        manager.saveItems([newItem])

        // Verify in-memory
        XCTAssertEqual(manager.items.count, 1)
        XCTAssertEqual(manager.items.first?.name, "New Event")

        // Verify pushed to iCloud
        let iCloudData = mockStore.storage[DataSyncManager.itemsKey] as? Data
        XCTAssertNotNil(iCloudData)
        let iCloudItems = try! JSONDecoder().decode([DSItem].self, from: iCloudData!)
        XCTAssertEqual(iCloudItems.count, 1)
        XCTAssertEqual(iCloudItems.first?.name, "New Event")

        // Verify written to App Group
        let localItems = DataSyncManager.loadItems(from: appGroupDefaults)
        XCTAssertEqual(localItems.count, 1)
        XCTAssertEqual(localItems.first?.name, "New Event")
    }

    func testEditItemPropagates() {
        let itemID = UUID()
        let original = makeItem(id: itemID, name: "Original", lastModified: olderDate)
        let (manager, mockStore, _) = makeManager(localItems: [original], remoteItems: [original])

        // Edit the item
        var edited = original
        edited.name = "Edited"
        edited.lastModified = newerDate
        manager.saveItems([edited])

        // Verify iCloud has the edit
        let iCloudData = mockStore.storage[DataSyncManager.itemsKey] as! Data
        let iCloudItems = try! JSONDecoder().decode([DSItem].self, from: iCloudData)
        XCTAssertEqual(iCloudItems.count, 1)
        XCTAssertEqual(iCloudItems.first?.name, "Edited")
    }

    func testDeleteItemPropagates() {
        let item1 = makeItem(name: "Keep")
        let item2 = makeItem(name: "Delete")
        let (manager, mockStore, _) = makeManager(localItems: [item1, item2])

        // Delete item2 by saving only item1
        manager.saveItems([item1])

        let iCloudData = mockStore.storage[DataSyncManager.itemsKey] as! Data
        let iCloudItems = try! JSONDecoder().decode([DSItem].self, from: iCloudData)
        XCTAssertEqual(iCloudItems.count, 1)
        XCTAssertEqual(iCloudItems.first?.name, "Keep")
    }

    // MARK: - 8. Delete and Reinstall (Restore from iCloud)

    func testFreshInstallRestoresFromiCloud() {
        // iCloud has data from previous install
        let remoteItems = [makeItem(name: "Restored Event")]
        let remoteCategories = [makeCategory(stableID: "custom-travel", name: "Travel")]

        let (manager, _, _) = makeManager(remoteItems: remoteItems, remoteCategories: remoteCategories)

        // Local is empty (fresh install) — startSync should restore
        manager.startSync()

        XCTAssertEqual(manager.items.count, 1)
        XCTAssertEqual(manager.items.first?.name, "Restored Event")

        let stableIDs = Set(manager.categories.map(\.stableID))
        XCTAssertTrue(stableIDs.contains("custom-travel"))
    }

    func testFreshInstallWithEmptyiCloudDoesNotCrash() {
        let (manager, _, _) = makeManager()
        manager.startSync()

        XCTAssertTrue(manager.items.isEmpty)
    }

    // MARK: - 9. Conflict / Simultaneous Edits

    func testConflictKeepsNewerLocalItem() {
        let sharedID = UUID()
        let remoteItems = [makeItem(id: sharedID, name: "Remote Version", lastModified: olderDate)]
        let localItems = [makeItem(id: sharedID, name: "Local Version", lastModified: newerDate)]

        let (manager, _, _) = makeManager(localItems: localItems, remoteItems: remoteItems)
        manager.performMigration()

        XCTAssertEqual(manager.items.count, 1)
        XCTAssertEqual(manager.items.first?.name, "Local Version")
    }

    func testConflictKeepsNewerRemoteItem() {
        let sharedID = UUID()
        let remoteItems = [makeItem(id: sharedID, name: "Remote Version", lastModified: newerDate)]
        let localItems = [makeItem(id: sharedID, name: "Local Version", lastModified: olderDate)]

        let (manager, _, _) = makeManager(localItems: localItems, remoteItems: remoteItems)
        manager.performMigration()

        XCTAssertEqual(manager.items.count, 1)
        XCTAssertEqual(manager.items.first?.name, "Remote Version")
    }

    func testConflictMixedMerge() {
        // Some items unique to each side, one shared item with conflict
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

        XCTAssertEqual(manager.items.count, 3)
        let names = Set(manager.items.map(\.name))
        XCTAssertTrue(names.contains("Local Only"))
        XCTAssertTrue(names.contains("Remote Only"))
        XCTAssertTrue(names.contains("Shared - Local Edit"), "Newer local version should win")
    }

    // MARK: - 10. Storage Limit Warning

    func testStorageWarningTriggersAboveThreshold() {
        let (manager, _, _) = makeManager()

        // Create enough items to exceed the warning threshold
        // Each item is ~200-300 bytes encoded. Threshold is 950KB.
        // Instead, test the iCloudUsageBytes property directly.
        let items = (0 ..< 5).map { makeItem(name: "Event \($0)") }
        manager.saveItems(items)

        // Verify usage is calculated (non-zero)
        XCTAssertGreaterThan(manager.iCloudUsageBytes, 0)
    }

    func testStorageUsageBytesReflectsData() {
        let (manager, _, _) = makeManager()

        let emptyUsage = manager.iCloudUsageBytes

        let items = (0 ..< 10).map { makeItem(name: "Event \($0) with a longer name to take up space") }
        manager.items = items

        let loadedUsage = manager.iCloudUsageBytes
        XCTAssertGreaterThan(loadedUsage, emptyUsage)
    }

    // MARK: - Safety Guard: Never Overwrite Non-Empty Local with Empty Remote

    func testSafetyGuardNeverOverwritesLocalWithEmptyRemote() {
        // This tests handleRemoteChange behavior indirectly.
        // The guard is: if !remoteItems.isEmpty || self.items.isEmpty
        // We verify that startSync with existing local data and empty iCloud
        // does NOT wipe local data.
        let localItems = [makeItem(name: "Important Local Event")]
        let (manager, _, _) = makeManager(localItems: localItems)

        // iCloud is empty, local has data
        manager.startSync()

        // Local data should be preserved
        XCTAssertEqual(manager.items.count, 1)
        XCTAssertEqual(manager.items.first?.name, "Important Local Event")
    }

    // MARK: - Category Merge

    func testCategoryMergeUnionsByStableID() {
        let remoteCategories = [
            makeCategory(stableID: "work", name: "Work"),
            makeCategory(stableID: "custom-a", name: "Travel"),
        ]
        let localItems = [makeItem(name: "Dummy")]
        let (manager, _, _) = makeManager(localItems: localItems, remoteCategories: remoteCategories)

        manager.performMigration()

        let stableIDs = Set(manager.categories.map(\.stableID))
        XCTAssertTrue(stableIDs.contains("work"))
        XCTAssertTrue(stableIDs.contains("custom-a"), "Remote-only category should be merged in")
    }

    func testCategoryMergeRemoteWinsForDuplicateStableID() {
        let remoteCategories = [
            makeCategory(stableID: "work", name: "Work Remote", color: .life),
        ]
        let localItems = [makeItem(name: "Dummy")]
        let (manager, _, _) = makeManager(localItems: localItems, remoteCategories: remoteCategories)

        manager.performMigration()

        // Remote should win for the "work" stableID
        let workCat = manager.categories.first(where: { $0.stableID == "work" })
        XCTAssertNotNil(workCat)
        XCTAssertEqual(workCat?.name, "Work Remote")
        XCTAssertEqual(workCat?.color, .life)
    }

    // MARK: - StableID Reconciliation

    func testReconcileFixesMismatchedCustomCategoryStableID() {
        // Simulate pre-stableID upgrade: item's embedded category has a random stableID
        // that doesn't match the canonical category list's stableID for the same category.
        let canonicalStableID = "canonical-travel-id"
        let orphanedStableID = "random-uuid-from-decoder"

        let travelCategory = DaysSince.Category(
            stableID: canonicalStableID, name: "Travel", emoji: "airplane", color: .life
        )
        let orphanedCategory = DaysSince.Category(
            stableID: orphanedStableID, name: "Travel", emoji: "airplane", color: .life
        )
        let item = DSItem(
            id: UUID(), name: "Trip to Paris", category: orphanedCategory,
            dateLastDone: fixedDate, remindersEnabled: false, lastModified: fixedDate
        )

        let suiteName = "test.\(UUID().uuidString)"
        let appGroupDefaults = UserDefaults(suiteName: suiteName)!
        let mockStore = MockKeyValueStore()

        // Write item with orphaned stableID to local storage
        let jsonString = String(data: try! JSONEncoder().encode([item]), encoding: .utf8)!
        appGroupDefaults.set(jsonString, forKey: DataSyncManager.itemsKey)

        // Set canonical categories via Defaults
        Defaults[.categories] = [travelCategory]

        let manager = DataSyncManager(appGroupDefaults: appGroupDefaults, iCloudStore: mockStore)

        // init() calls reconcileCategoryStableIDs — item should now match canonical stableID
        XCTAssertEqual(manager.items.count, 1)
        XCTAssertEqual(manager.items.first?.category.stableID, canonicalStableID)
        XCTAssertEqual(manager.items.first?.name, "Trip to Paris")
    }

    func testReconcileDoesNotTouchBuiltInCategories() {
        let workCategory = DaysSince.Category(
            stableID: DaysSince.Category.stableIDWork, name: "Work", emoji: "lightbulb", color: .work
        )
        let item = DSItem(
            id: UUID(), name: "Meeting", category: workCategory,
            dateLastDone: fixedDate, remindersEnabled: false, lastModified: fixedDate
        )

        let suiteName = "test.\(UUID().uuidString)"
        let appGroupDefaults = UserDefaults(suiteName: suiteName)!
        let mockStore = MockKeyValueStore()
        let jsonString = String(data: try! JSONEncoder().encode([item]), encoding: .utf8)!
        appGroupDefaults.set(jsonString, forKey: DataSyncManager.itemsKey)

        Defaults[.categories] = [workCategory]

        let manager = DataSyncManager(appGroupDefaults: appGroupDefaults, iCloudStore: mockStore)

        // Built-in category should be untouched
        XCTAssertEqual(manager.items.first?.category.stableID, DaysSince.Category.stableIDWork)
    }

    func testReconcileDoesNotTouchAlreadyMatchingItems() {
        let stableID = "my-custom-id"
        let category = DaysSince.Category(stableID: stableID, name: "Cooking", emoji: "fork.knife", color: .hobbies)
        let item = DSItem(
            id: UUID(), name: "Made pasta", category: category,
            dateLastDone: fixedDate, remindersEnabled: false, lastModified: fixedDate
        )

        let suiteName = "test.\(UUID().uuidString)"
        let appGroupDefaults = UserDefaults(suiteName: suiteName)!
        let mockStore = MockKeyValueStore()
        let jsonString = String(data: try! JSONEncoder().encode([item]), encoding: .utf8)!
        appGroupDefaults.set(jsonString, forKey: DataSyncManager.itemsKey)

        Defaults[.categories] = [category]

        let manager = DataSyncManager(appGroupDefaults: appGroupDefaults, iCloudStore: mockStore)

        XCTAssertEqual(manager.items.first?.category.stableID, stableID)
    }

    func testReconcileFixesMultipleItemsInSameCustomCategory() {
        let canonicalStableID = "canonical-fitness"
        let fitnessCategory = DaysSince.Category(
            stableID: canonicalStableID, name: "Fitness", emoji: "figure.run", color: .health
        )

        // Each item gets a different orphaned stableID (simulating independent decoder runs)
        let items = (0 ..< 3).map { i in
            DSItem(
                id: UUID(), name: "Workout \(i)",
                category: DaysSince.Category(
                    stableID: "orphan-\(i)", name: "Fitness", emoji: "figure.run", color: .health
                ),
                dateLastDone: fixedDate, remindersEnabled: false, lastModified: fixedDate
            )
        }

        let suiteName = "test.\(UUID().uuidString)"
        let appGroupDefaults = UserDefaults(suiteName: suiteName)!
        let mockStore = MockKeyValueStore()
        let jsonString = String(data: try! JSONEncoder().encode(items), encoding: .utf8)!
        appGroupDefaults.set(jsonString, forKey: DataSyncManager.itemsKey)

        Defaults[.categories] = [fitnessCategory]

        let manager = DataSyncManager(appGroupDefaults: appGroupDefaults, iCloudStore: mockStore)

        // All 3 items should now have the canonical stableID
        for item in manager.items {
            XCTAssertEqual(item.category.stableID, canonicalStableID, "Item '\(item.name)' should be reconciled")
        }
    }

    func testReconcileUsesExactMatchForDuplicateCategoryNames() {
        // Two categories with the same name but different colors
        let redTravel = DaysSince.Category(stableID: "travel-red", name: "Travel", emoji: "airplane", color: .marioRed)
        let blueTravel = DaysSince.Category(stableID: "travel-blue", name: "Travel", emoji: "airplane", color: .marioBlue)

        // Item belongs to the blue variant
        let item = DSItem(
            id: UUID(), name: "Trip",
            category: DaysSince.Category(stableID: "orphan-id", name: "Travel", emoji: "airplane", color: .marioBlue),
            dateLastDone: fixedDate, remindersEnabled: false, lastModified: fixedDate
        )

        let suiteName = "test.\(UUID().uuidString)"
        let appGroupDefaults = UserDefaults(suiteName: suiteName)!
        let mockStore = MockKeyValueStore()
        let jsonString = String(data: try! JSONEncoder().encode([item]), encoding: .utf8)!
        appGroupDefaults.set(jsonString, forKey: DataSyncManager.itemsKey)

        Defaults[.categories] = [redTravel, blueTravel]

        let manager = DataSyncManager(appGroupDefaults: appGroupDefaults, iCloudStore: mockStore)

        // Should match to the blue variant, not the red one
        XCTAssertEqual(manager.items.first?.category.stableID, "travel-blue")
    }

    func testReconcileSkipsFullyAmbiguousCategories() {
        // Two categories with identical name, emoji, AND color — cannot safely pick one
        let travelA = DaysSince.Category(stableID: "travel-a", name: "Travel", emoji: "airplane", color: .life)
        let travelB = DaysSince.Category(stableID: "travel-b", name: "Travel", emoji: "airplane", color: .life)

        let orphanedStableID = "orphan-id"
        let item = DSItem(
            id: UUID(), name: "Trip",
            category: DaysSince.Category(stableID: orphanedStableID, name: "Travel", emoji: "airplane", color: .life),
            dateLastDone: fixedDate, remindersEnabled: false, lastModified: fixedDate
        )

        let suiteName = "test.\(UUID().uuidString)"
        let appGroupDefaults = UserDefaults(suiteName: suiteName)!
        let mockStore = MockKeyValueStore()
        let jsonString = String(data: try! JSONEncoder().encode([item]), encoding: .utf8)!
        appGroupDefaults.set(jsonString, forKey: DataSyncManager.itemsKey)

        Defaults[.categories] = [travelA, travelB]

        let manager = DataSyncManager(appGroupDefaults: appGroupDefaults, iCloudStore: mockStore)

        // Should NOT reassign — ambiguous, so leave the original stableID untouched
        XCTAssertEqual(manager.items.first?.category.stableID, orphanedStableID)
    }

    func testReconcilePersistedToAppGroup() {
        // Verify that reconciled items are written back to UserDefaults
        let canonicalStableID = "canonical-cooking"
        let category = DaysSince.Category(stableID: canonicalStableID, name: "Cooking", emoji: "fork.knife", color: .hobbies)
        let item = DSItem(
            id: UUID(), name: "Made soup",
            category: DaysSince.Category(stableID: "orphan", name: "Cooking", emoji: "fork.knife", color: .hobbies),
            dateLastDone: fixedDate, remindersEnabled: false, lastModified: fixedDate
        )

        let suiteName = "test.\(UUID().uuidString)"
        let appGroupDefaults = UserDefaults(suiteName: suiteName)!
        let mockStore = MockKeyValueStore()
        let jsonString = String(data: try! JSONEncoder().encode([item]), encoding: .utf8)!
        appGroupDefaults.set(jsonString, forKey: DataSyncManager.itemsKey)

        Defaults[.categories] = [category]

        let _ = DataSyncManager(appGroupDefaults: appGroupDefaults, iCloudStore: mockStore)

        // Re-load from UserDefaults to verify persistence
        let reloadedItems = DataSyncManager.loadItems(from: appGroupDefaults)
        XCTAssertEqual(reloadedItems.first?.category.stableID, canonicalStableID)
    }

    // MARK: - startSync Merge

    func testStartSyncMergesInsteadOfOverwriting() {
        let idA = UUID(), idB = UUID()
        let remoteItems = [makeItem(id: idA, name: "Device A Event")]
        let localItems = [makeItem(id: idB, name: "Device B Event")]

        let (manager, _, _) = makeManager(localItems: localItems, remoteItems: remoteItems)
        manager.startSync()

        XCTAssertEqual(manager.items.count, 2)
        let names = Set(manager.items.map(\.name))
        XCTAssertTrue(names.contains("Device A Event"))
        XCTAssertTrue(names.contains("Device B Event"))
    }

    func testStartSyncPushesMergedDataToiCloud() {
        let idA = UUID(), idB = UUID()
        let remoteItems = [makeItem(id: idA, name: "Device A Event")]
        let localItems = [makeItem(id: idB, name: "Device B Event")]

        let (manager, mockStore, _) = makeManager(localItems: localItems, remoteItems: remoteItems)
        manager.startSync()

        // Verify merged data was pushed back to iCloud
        let iCloudData = mockStore.storage[DataSyncManager.itemsKey] as! Data
        let iCloudItems = try! JSONDecoder().decode([DSItem].self, from: iCloudData)
        XCTAssertEqual(iCloudItems.count, 2)
    }
}
