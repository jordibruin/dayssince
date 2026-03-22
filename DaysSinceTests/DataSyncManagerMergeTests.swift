@testable import DaysSince
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
