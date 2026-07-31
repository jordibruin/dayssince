@testable import DaysSince
import Foundation
import Testing

/// Drives `applyRemoteChange(reason:)` directly — the synchronous half of the
/// `NSUbiquitousKeyValueStore.didChangeExternallyNotification` handler.
extension GlobalStateSuite {

    @Suite("DataSyncManager remote changes")
    struct DataSyncRemoteChangeTests {

        private struct Harness {
            let manager: DataSyncManager
            let kvs: MockKeyValueStore
            let categoryStore: MockCategoryStore
            let reloader: SpyWidgetReloader
            let appGroup: IsolatedDefaults
        }

        private func makeHarness(
            localItems: [DSItem] = [],
            remoteItems: [DSItem]? = nil,
            remoteCategories: [DaysSince.Category]? = nil
        ) throws -> Harness {
            let appGroup = IsolatedDefaults()
            if !localItems.isEmpty {
                let json = try String(data: JSONEncoder().encode(localItems), encoding: .utf8)
                appGroup.defaults.set(json, forKey: DataSyncManager.itemsKey)
            }

            let kvs = MockKeyValueStore()
            if let remoteItems {
                kvs.encode(remoteItems, forKey: DataSyncManager.itemsKey)
            }
            if let remoteCategories {
                kvs.encode(remoteCategories, forKey: DataSyncManager.categoriesKey)
            }

            let categoryStore = MockCategoryStore()
            let reloader = SpyWidgetReloader()

            return Harness(
                manager: DataSyncManager(
                    appGroupDefaults: appGroup.defaults,
                    iCloudStore: kvs,
                    categoryStore: categoryStore,
                    widgetReloader: reloader
                ),
                kvs: kvs,
                categoryStore: categoryStore,
                reloader: reloader,
                appGroup: appGroup
            )
        }

        // MARK: - Server change

        @Test("a non-empty remote replaces local items and mirrors them to the App Group")
        func serverChangeAppliesRemoteItems() throws {
            let harness = try makeHarness(
                localItems: [Fixtures.item(name: "Local")],
                remoteItems: [Fixtures.item(name: "Remote A"), Fixtures.item(name: "Remote B")]
            )

            harness.manager.applyRemoteChange(reason: NSUbiquitousKeyValueStoreServerChange)

            #expect(harness.manager.items.map(\.name).sorted() == ["Remote A", "Remote B"])
            #expect(DataSyncManager.loadItems(from: harness.appGroup.defaults).count == 2)
        }

        /// The data-loss guard: an empty iCloud payload must never wipe local events.
        @Test("an empty remote never wipes non-empty local items")
        func serverChangeKeepsLocalWhenRemoteIsEmpty() throws {
            let harness = try makeHarness(localItems: [Fixtures.item(name: "Local")], remoteItems: [])

            harness.manager.applyRemoteChange(reason: NSUbiquitousKeyValueStoreServerChange)

            #expect(harness.manager.items.map(\.name) == ["Local"])
            #expect(DataSyncManager.loadItems(from: harness.appGroup.defaults).map(\.name) == ["Local"])
        }

        @Test("an empty remote is applied when local is also empty")
        func serverChangeAppliesEmptyToEmpty() throws {
            let harness = try makeHarness(localItems: [], remoteItems: [])

            harness.manager.applyRemoteChange(reason: NSUbiquitousKeyValueStoreServerChange)

            #expect(harness.manager.items.isEmpty)
        }

        @Test("remote categories replace the stored categories")
        func serverChangeAppliesRemoteCategories() throws {
            let remote = [Fixtures.category(stableID: "pets", name: "Pets", emoji: "pawprint", color: .marioBlue)]
            let harness = try makeHarness(remoteCategories: remote)

            harness.manager.applyRemoteChange(reason: NSUbiquitousKeyValueStoreServerChange)

            #expect(harness.manager.categories.map(\.stableID) == ["pets"])
            #expect(harness.categoryStore.categories.map(\.stableID) == ["pets"])
        }

        @Test("empty remote categories leave the local list alone")
        func serverChangeKeepsCategoriesWhenRemoteIsEmpty() throws {
            let harness = try makeHarness(remoteCategories: [])

            harness.manager.applyRemoteChange(reason: NSUbiquitousKeyValueStoreServerChange)

            #expect(harness.categoryStore.categories == DaysSince.Category.builtInDefaults)
        }

        @Test("a server change reloads the widget timelines exactly once")
        func serverChangeReloadsWidgetsOnce() throws {
            let harness = try makeHarness(remoteItems: [Fixtures.item()])

            harness.manager.applyRemoteChange(reason: NSUbiquitousKeyValueStoreServerChange)

            #expect(harness.reloader.reloadCount == 1)
        }

        // MARK: - Conflict analytics

        @Test("a differing item count is reported as a sync conflict")
        func conflictAnalyticsWhenCountsDiffer() throws {
            let harness = try makeHarness(
                localItems: [Fixtures.item(name: "Local")],
                remoteItems: [Fixtures.item(name: "A"), Fixtures.item(name: "B")]
            )

            withAnalyticsSpy { spy in
                harness.manager.applyRemoteChange(reason: NSUbiquitousKeyValueStoreServerChange)

                #expect(spy.count(of: .iCloudSyncConflict) == 1)
                #expect(spy.parameters(of: .iCloudSyncConflict) == ["localCount": "1", "remoteCount": "2"])
            }
        }

        @Test("a matching item count is not reported as a conflict")
        func noConflictAnalyticsWhenCountsMatch() throws {
            let harness = try makeHarness(
                localItems: [Fixtures.item(name: "Local")],
                remoteItems: [Fixtures.item(name: "Remote")]
            )

            withAnalyticsSpy { spy in
                harness.manager.applyRemoteChange(reason: NSUbiquitousKeyValueStoreServerChange)

                #expect(spy.count(of: .iCloudSyncConflict) == 0)
            }
        }

        @Test("the initial-sync branch never reports a conflict")
        func initialSyncLogsNoConflict() throws {
            let harness = try makeHarness(
                localItems: [Fixtures.item(name: "Local")],
                remoteItems: [Fixtures.item(name: "A"), Fixtures.item(name: "B")]
            )

            withAnalyticsSpy { spy in
                harness.manager.applyRemoteChange(reason: NSUbiquitousKeyValueStoreInitialSyncChange)

                #expect(spy.count(of: .iCloudSyncConflict) == 0)
            }
        }

        // MARK: - Initial sync

        @Test("initial sync applies remote items and reloads widgets once")
        func initialSyncAppliesRemoteItems() throws {
            let harness = try makeHarness(remoteItems: [Fixtures.item(name: "Remote")])

            harness.manager.applyRemoteChange(reason: NSUbiquitousKeyValueStoreInitialSyncChange)

            #expect(harness.manager.items.map(\.name) == ["Remote"])
            #expect(DataSyncManager.loadItems(from: harness.appGroup.defaults).map(\.name) == ["Remote"])
            #expect(harness.reloader.reloadCount == 1)
        }

        /// Unlike the server-change branch, initial sync only ever adds — it cannot clear
        /// local items, so an empty remote is a no-op even when local is empty.
        @Test("initial sync with an empty remote changes nothing")
        func initialSyncWithEmptyRemoteIsNoOp() throws {
            let harness = try makeHarness(localItems: [Fixtures.item(name: "Local")], remoteItems: [])

            harness.manager.applyRemoteChange(reason: NSUbiquitousKeyValueStoreInitialSyncChange)

            #expect(harness.manager.items.map(\.name) == ["Local"])
        }

        // MARK: - Other reasons

        /// **Known gap, not intended behaviour.** `applyRemoteChange` handles only
        /// `ServerChange` and `InitialSyncChange`, so two reasons fall through:
        ///
        /// - `AccountChange` — the user signed into a different iCloud account. The app keeps the
        ///   previous account's items in memory and pushes them up on the next write, which is
        ///   cross-account data leakage.
        /// - `QuotaViolationChange` — the only authoritative signal that iCloud *rejected* a
        ///   write. The 1 MB warning (`shouldWarnAboutStorage`) is built on an estimate and
        ///   ignores this.
        ///
        /// This test pins the current behaviour so that fixing either one is a visible, deliberate
        /// change rather than an accident. It is not a specification of what should happen.
        @Test(
            "quota-violation and account-change reasons currently fall through unhandled",
            arguments: [NSUbiquitousKeyValueStoreQuotaViolationChange, NSUbiquitousKeyValueStoreAccountChange]
        )
        func unhandledReasonsAreIgnored(reason: Int) throws {
            let harness = try makeHarness(
                localItems: [Fixtures.item(name: "Local")],
                remoteItems: [Fixtures.item(name: "Remote")]
            )

            harness.manager.applyRemoteChange(reason: reason)

            #expect(harness.manager.items.map(\.name) == ["Local"])
            #expect(harness.reloader.reloadCount == 0)
        }

    }
}
