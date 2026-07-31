//
//  DaysSinceApp.swift
//  DaysSince
//
//  Created by Vicki Minerva on 3/28/22.
//

import Defaults
import StoreKit
import SwiftUI
import WidgetKit
import TelemetryDeck

@main
struct DaysSinceApp: App {
    // Every manager is constructed in `init()` rather than inline, because property
    // initializers run *before* the init body and would read storage ahead of the UI-test reset.
    @StateObject var dataSyncManager: DataSyncManager
    @StateObject var notificationManager: NotificationManager
    @StateObject var categoryManager: CategoryManager
    @StateObject var subscriptionManager: SubscriptionManager
    @StateObject var reviewManager: ReviewManager

    init() {
        TestHooks.resetStateIfRequested()

        let dataSync = DataSyncManager(iCloudStore: TestHooks.makeICloudStore())
        _dataSyncManager = StateObject(wrappedValue: dataSync)
        _notificationManager = StateObject(wrappedValue: NotificationManager())
        _categoryManager = StateObject(wrappedValue: CategoryManager())
        _subscriptionManager = StateObject(
            wrappedValue: SubscriptionManager(autoStart: TestHooks.forcedSubscription == nil)
        )
        _reviewManager = StateObject(
            wrappedValue: TestHooks.reviewPromptSuppressed
                ? ReviewManager(presentReview: { false })
                : ReviewManager()
        )

        if TestHooks.animationsDisabled {
            UIView.setAnimationsEnabled(false)
        }

        if !TestHooks.networkDisabled {
            let config = TelemetryDeck.Config(appID: "FBE58244-22B0-4207-9ED7-052DEB5B8A26")
            config.defaultSignalPrefix = "DaysSince."
            config.testMode = isSimulatorOrTestFlight()
            TelemetryDeck.initialize(config: config)
        }
//        Analytics.send(.launchApp)

        #if DEBUG
        Self.applyDebugLaunchFlags(dataSyncManager: dataSync)
        #endif
    }

    @AppStorage("hasSeenOnboarding") var hasSeenOnboarding = false
    @AppStorage("iCloudMigrationComplete") var iCloudMigrationComplete = false

    @Environment(\.scenePhase) var scenePhase

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(dataSyncManager)
                .environmentObject(notificationManager)
                .environmentObject(categoryManager)
                .environmentObject(subscriptionManager)
                .environmentObject(reviewManager)
                .onChange(of: self.scenePhase) {
                    switch $0 {
                    case .active:
                        // Trigger iCloud sync when app comes to foreground
                        _ = NSUbiquitousKeyValueStore.default.synchronize()
                    case .background:
                        WidgetCenter.shared.reloadAllTimelines()
                    default: break
                    }
                }
                .onAppear {
                    categoryManager.dataSyncManager = dataSyncManager
                    dataSyncManager.startSync()

                    if let forced = TestHooks.forcedSubscription {
                        subscriptionManager.applyEntitlement(hasActive: forced)
                    }
                }
        }
    }

    #if DEBUG
    /// The routing flags have to be written *before the first render*. Flipping them afterwards
    /// makes `ContentView` leave its onboarding branch, and `OnboardingRootView.onDisappear` sets
    /// `iCloudMigrationComplete = true` on the way out — which silently skipped the migration
    /// screen a test had asked for.
    private static func applyDebugLaunchFlags(dataSyncManager: DataSyncManager) {
        let arguments = CommandLine.arguments
        let defaults = UserDefaults.standard

        if arguments.contains("-seedDemoData") {
            seedDemoData(into: dataSyncManager)
            defaults.set(true, forKey: "hasSeenOnboarding")
            defaults.set(true, forKey: "iCloudMigrationComplete")
        }
        if arguments.contains("-showOnboarding") {
            defaults.set(false, forKey: "hasSeenOnboarding")
        }
        if arguments.contains("-showICloudMigration") {
            defaults.set(true, forKey: "hasSeenOnboarding")
            defaults.set(false, forKey: "iCloudMigrationComplete")
        }
    }

    private static func seedDemoData(into dataSyncManager: DataSyncManager) {
        // Seed all sample categories
        let categories = Category.sampleList
        Defaults[.categories] = categories

        // Build DSItems from the onboarding event suggestions
        let eventsByCategory: [(category: Category, name: String, daysAgo: Int)] = [
            (categories[0], "📊 Performance review", 30),
            (categories[0], "💼 Resume update", 90),
            (categories[1], "✂️ Haircut", 37),
            (categories[1], "👯 Hung out with friends", 3),
            (categories[2], "🏃‍♂️ Work out", 1),
            (categories[2], "🎮 Game night", 7),
            (categories[3], "🏥 Dentist visit", 180),
            (categories[3], "💊 Vitamins refill", 30),
            (categories[4], "💧 Water filter change", 60),
            (categories[5], "🐾 Cat litter", 17),
            (categories[5], "💉 Dog vaccination", 365),
            (categories[6], "🎁 Birthday gift", 14),
            (categories[7], "🔨 Side project update", 7),
            (categories[7], "📝 Blog post", 30),
            (categories[8], "📓 Journaled", 1),
            (categories[8], "🧘 Meditation", 2),
        ]

        let items = eventsByCategory.map { entry in
            DSItem(
                id: UUID(),
                name: entry.name,
                category: entry.category,
                dateLastDone: Calendar.daysAgo(entry.daysAgo),
                remindersEnabled: false
            )
        }

        dataSyncManager.saveItems(items)
        dataSyncManager.syncCategories()
    }
    #endif
}
