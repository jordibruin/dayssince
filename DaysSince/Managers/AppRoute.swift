//
//  AppRoute.swift
//  DaysSince
//

import Foundation

/// Which screen the app opens on. Extracted from `ContentView` so the four-state table in
/// CLAUDE.md is asserted by tests rather than by reading a nested `if`.
enum AppRoute: Equatable {
    case onboarding
    case iCloudMigration
    case main

    /// Onboarding wins outright: a reinstall has `iCloudMigrationComplete == true` (set by
    /// `DataSyncManager.startSync()` when it restores from iCloud) but still needs onboarding,
    /// because `hasSeenOnboarding` lives in UserDefaults and was wiped with the app.
    static func route(hasSeenOnboarding: Bool, iCloudMigrationComplete: Bool) -> AppRoute {
        guard hasSeenOnboarding else { return .onboarding }
        return iCloudMigrationComplete ? .main : .iCloudMigration
    }
}
