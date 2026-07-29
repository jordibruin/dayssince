@testable import DaysSince
import Foundation
import Testing

extension GlobalStateSuite {

    @Suite("iCloud storage limit")
    struct ICloudStorageLimitTests {

        private func makeManager(_ reloader: SpyWidgetReloader = SpyWidgetReloader()) -> DataSyncManager {
            DataSyncManager(
                appGroupDefaults: IsolatedDefaults().defaults,
                iCloudStore: MockKeyValueStore(),
                categoryStore: MockCategoryStore(),
                widgetReloader: reloader
            )
        }

        @Test("the warning threshold is 950 KB of the 1 MB limit")
        func thresholdConstants() {
            #expect(DataSyncManager.iCloudKVSLimit == 1_048_576)
            #expect(DataSyncManager.iCloudKVSWarningThreshold == 972_800)
        }

        @Test(
            "the warning trips at the threshold, not below it",
            arguments: [
                (0, false),
                (972_799, false),
                (972_800, true),
                (1_048_576, true),
            ]
        )
        func warningBoundary(usage: Int, expected: Bool) {
            #expect(DataSyncManager.shouldWarnAboutStorage(usage: usage) == expected)
        }

        @Test("usage sums the encoded items and categories")
        func usageSumsBothKeys() throws {
            let manager = makeManager()
            manager.saveItems([Fixtures.item(name: "Dentist")])

            let itemsSize = try JSONEncoder().encode(manager.items).count
            let categoriesSize = try JSONEncoder().encode(manager.categories).count

            #expect(manager.iCloudUsageBytes == itemsSize + categoriesSize)
        }

        @Test("a small data set does not trip the warning")
        func smallDataSetDoesNotWarn() {
            let manager = makeManager()

            manager.saveItems([Fixtures.item(name: "Dentist")])

            #expect(manager.showiCloudStorageWarning == false)
        }

        @Test("a data set past the threshold trips the warning")
        func largeDataSetWarns() {
            let manager = makeManager()

            manager.saveItems([Fixtures.item(name: String(repeating: "a", count: 1_000_000))])

            #expect(manager.iCloudUsageBytes > DataSyncManager.iCloudKVSWarningThreshold)
            #expect(manager.showiCloudStorageWarning == true)
        }

        @Test("the warning clears once the data set shrinks again")
        func warningClearsWhenDataShrinks() {
            let manager = makeManager()

            manager.saveItems([Fixtures.item(name: String(repeating: "a", count: 1_000_000))])
            manager.saveItems([Fixtures.item(name: "Dentist")])

            #expect(manager.showiCloudStorageWarning == false)
        }

        @Test("saving reports the data size to analytics")
        func reportsDataSize() {
            let manager = makeManager()

            withAnalyticsSpy { spy in
                manager.saveItems([Fixtures.item(name: "Dentist")])

                #expect(spy.count(of: .iCloudDataSize) == 1)
                #expect(spy.parameters(of: .iCloudDataSize) == ["bytes": String(manager.iCloudUsageBytes)])
            }
        }
    }
}
