//
//  DataSyncManager.swift
//  DaysSince
//
//  Created by Victoria Petrova on 21/03/2026.
//

import Defaults
import Foundation
import SwiftUI
import WidgetKit

/// Protocol for key-value store abstraction (enables testing with a mock).
protocol KeyValueStoreProtocol {
    func data(forKey key: String) -> Data?
    func set(_ value: Any?, forKey key: String)
    func synchronize() -> Bool
}

extension NSUbiquitousKeyValueStore: KeyValueStoreProtocol {}

/// Central coordinator for syncing data between App Group UserDefaults, iCloud (NSUbiquitousKeyValueStore),
/// and the in-memory published properties that drive the UI.
class DataSyncManager: ObservableObject {

    // MARK: - Published State

    @Published var items: [DSItem] = []
    @Published var categories: [Category] = []

    /// Set to true when iCloud storage usage exceeds the warning threshold.
    @Published var showiCloudStorageWarning = false

    // MARK: - Storage

    private let appGroupDefaults: UserDefaults
    private let iCloudStore: KeyValueStoreProtocol

    // MARK: - Constants

    /// NSUbiquitousKeyValueStore has a hard 1 MB (1,048,576 bytes) limit.
    static let iCloudKVSLimit = 1_048_576
    /// Warn the user when usage exceeds 950 KB.
    static let iCloudKVSWarningThreshold = 950 * 1024

    // MARK: - Keys

    static let itemsKey = "items"
    static let categoriesKey = "icloud_categories"

    // MARK: - Init

    init(
        appGroupDefaults: UserDefaults? = UserDefaults(suiteName: "group.goodsnooze.dayssince"),
        iCloudStore: KeyValueStoreProtocol = NSUbiquitousKeyValueStore.default
    ) {
        self.appGroupDefaults = appGroupDefaults ?? .standard
        self.iCloudStore = iCloudStore

        // Load items from App Group UserDefaults (source of truth for initial load)
        self.items = Self.loadItems(from: self.appGroupDefaults)

        // Load categories from Defaults library (current source of truth)
        self.categories = Defaults[.categories]
    }

    // MARK: - Sync Lifecycle

    /// Call on app launch to register for iCloud change notifications and trigger initial sync.
    func startSync() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleRemoteChange(_:)),
            name: NSUbiquitousKeyValueStore.didChangeExternallyNotification,
            object: nil
        )

        // Trigger initial sync from iCloud
        _ = iCloudStore.synchronize()

        // If local items are empty (e.g. fresh install / reinstall), restore from iCloud.
        // We use items as the signal because they have no built-in defaults —
        // categories always have 4 defaults from the Defaults library, so checking
        // categories.isEmpty would never detect a fresh install.
        if items.isEmpty {
            // Also restore categories from iCloud on fresh install
            let remoteCategories = loadCategoriesFromiCloud()
            if !remoteCategories.isEmpty {
                categories = remoteCategories
                Defaults[.categories] = remoteCategories
            }

            let remoteItems = loadItemsFromiCloud()
            if !remoteItems.isEmpty {
                items = remoteItems
                writeItemsToAppGroup(remoteItems)

                // Mark migration as complete — data is already in iCloud
                UserDefaults.standard.set(true, forKey: "iCloudMigrationComplete")
            }

            WidgetCenter.shared.reloadAllTimelines()
        } else {
            // Normal launch with existing local data — push to iCloud
            pushItemsToiCloud()
            pushCategoriesToiCloud()
        }
    }

    // MARK: - Items CRUD

    /// Save items to both local storage and iCloud.
    func saveItems(_ newItems: [DSItem]) {
        items = newItems
        writeItemsToAppGroup(newItems)
        pushItemsToiCloud()
        WidgetCenter.shared.reloadAllTimelines()
    }

    /// Reload items from App Group UserDefaults (e.g., after onboarding writes directly to AppStorage).
    func reloadFromAppGroup() {
        let freshItems = Self.loadItems(from: appGroupDefaults)
        items = freshItems
        pushItemsToiCloud()

        categories = Defaults[.categories]
        pushCategoriesToiCloud()
    }

    // MARK: - Categories Sync

    /// Sync categories to iCloud after a local change.
    func syncCategories() {
        categories = Defaults[.categories]
        pushCategoriesToiCloud()
    }

    // MARK: - Migration

    /// Migrate existing UserDefaults data to iCloud. Called once for existing users.
    /// Returns the number of items and categories migrated.
    @discardableResult
    func performMigration() -> (items: Int, categories: Int) {
        Analytics.send(.iCloudMigrationStarted)

        // Load current items from App Group UserDefaults
        let currentItems = Self.loadItems(from: appGroupDefaults)
        items = currentItems

        // Load current categories from Defaults
        categories = Defaults[.categories]

        // Push to iCloud
        pushItemsToiCloud()
        pushCategoriesToiCloud()

        // Force sync
        _ = iCloudStore.synchronize()

        Analytics.send(.iCloudMigrationCompleted, with: [
            "itemCount": String(currentItems.count),
            "categoryCount": String(categories.count)
        ])

        return (currentItems.count, categories.count)
    }

    // MARK: - iCloud Availability

    /// Whether iCloud is available for the current user.
    var isiCloudAvailable: Bool {
        FileManager.default.ubiquityIdentityToken != nil
    }

    // MARK: - Remote Change Handling

    @objc private func handleRemoteChange(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let reasonRaw = userInfo[NSUbiquitousKeyValueStoreChangeReasonKey] as? Int else {
            return
        }

        let reason = reasonRaw

        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }

            // Log conflicts
            if reason == NSUbiquitousKeyValueStoreServerChange {
                let localCount = self.items.count
                let remoteItems = self.loadItemsFromiCloud()
                let remoteCount = remoteItems.count

                if localCount != remoteCount {
                    Analytics.send(.iCloudSyncConflict, with: [
                        "localCount": String(localCount),
                        "remoteCount": String(remoteCount)
                    ])
                }

                // Apply remote items — but never overwrite local data with empty remote data
                if !remoteItems.isEmpty || self.items.isEmpty {
                    self.items = remoteItems
                    self.writeItemsToAppGroup(remoteItems)
                }

                // Apply remote categories
                let remoteCategories = self.loadCategoriesFromiCloud()
                if !remoteCategories.isEmpty {
                    self.categories = remoteCategories
                    Defaults[.categories] = remoteCategories
                }

                WidgetCenter.shared.reloadAllTimelines()
            } else if reason == NSUbiquitousKeyValueStoreInitialSyncChange {
                // Initial sync after iCloud account change — merge remote data
                let remoteItems = self.loadItemsFromiCloud()
                if !remoteItems.isEmpty {
                    self.items = remoteItems
                    self.writeItemsToAppGroup(remoteItems)
                }

                let remoteCategories = self.loadCategoriesFromiCloud()
                if !remoteCategories.isEmpty {
                    self.categories = remoteCategories
                    Defaults[.categories] = remoteCategories
                }

                WidgetCenter.shared.reloadAllTimelines()
            }
        }
    }

    // MARK: - Storage Size Check

    /// Total bytes currently used across all iCloud KVS keys.
    var iCloudUsageBytes: Int {
        let itemsSize = (try? JSONEncoder().encode(items))?.count ?? 0
        let categoriesSize = (try? JSONEncoder().encode(categories))?.count ?? 0
        return itemsSize + categoriesSize
    }

    /// Checks if iCloud KVS usage is approaching the 1 MB limit and updates the warning flag.
    private func checkStorageUsage() {
        let usage = iCloudUsageBytes
        let shouldWarn = usage >= Self.iCloudKVSWarningThreshold

        if shouldWarn != showiCloudStorageWarning {
            showiCloudStorageWarning = shouldWarn
        }

        // Log data size for telemetry
        Analytics.send(.iCloudDataSize, with: ["bytes": String(usage)])
    }

    // MARK: - Private Helpers

    private func pushItemsToiCloud() {
        guard let data = try? JSONEncoder().encode(items) else { return }
        iCloudStore.set(data, forKey: Self.itemsKey)
        checkStorageUsage()
    }

    private func pushCategoriesToiCloud() {
        guard let data = try? JSONEncoder().encode(categories) else { return }
        iCloudStore.set(data, forKey: Self.categoriesKey)
    }

    /// Write items to App Group UserDefaults as a JSON string.
    /// Must match the format used by @AppStorage with RawRepresentable arrays.
    private func writeItemsToAppGroup(_ items: [DSItem]) {
        guard let data = try? JSONEncoder().encode(items),
              let jsonString = String(data: data, encoding: .utf8) else { return }
        appGroupDefaults.set(jsonString, forKey: Self.itemsKey)
    }

    private func loadItemsFromiCloud() -> [DSItem] {
        guard let data = iCloudStore.data(forKey: Self.itemsKey),
              let items = try? JSONDecoder().decode([DSItem].self, from: data) else {
            return []
        }
        return items
    }

    private func loadCategoriesFromiCloud() -> [Category] {
        guard let data = iCloudStore.data(forKey: Self.categoriesKey),
              let categories = try? JSONDecoder().decode([Category].self, from: data) else {
            return []
        }
        return categories
    }

    /// Load items from UserDefaults.
    /// @AppStorage stores arrays as JSON strings (via RawRepresentable), so we read as String first.
    static func loadItems(from defaults: UserDefaults) -> [DSItem] {
        // @AppStorage uses RawRepresentable which stores as a JSON string
        if let jsonString = defaults.string(forKey: itemsKey),
           let data = jsonString.data(using: .utf8),
           let items = try? JSONDecoder().decode([DSItem].self, from: data) {
            return items
        }
        // Fallback: try reading as Data (for DataSyncManager's own writes)
        if let data = defaults.data(forKey: itemsKey),
           let items = try? JSONDecoder().decode([DSItem].self, from: data) {
            return items
        }
        return []
    }
}
