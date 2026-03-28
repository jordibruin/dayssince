//
//  DaysSinceApp.swift
//  DaysSince
//
//  Created by Vicki Minerva on 3/28/22.
//

import Defaults
import SwiftUI
import WidgetKit
import TelemetryDeck

@main
struct DaysSinceApp: App {
    @StateObject var dataSyncManager = DataSyncManager()
    @StateObject var notificationManager = NotificationManager()
    @StateObject var categoryManager = CategoryManager()
    @StateObject var reviewManager: ReviewManager

    init() {
        let reviewManager = ReviewManager()
        _reviewManager = StateObject(wrappedValue: reviewManager)
        let config = TelemetryDeck.Config(appID: "FBE58244-22B0-4207-9ED7-052DEB5B8A26")
        config.defaultSignalPrefix = "DaysSince."
        config.testMode = isSimulatorOrTestFlight()
        TelemetryDeck.initialize(config: config)
//        Analytics.send(.launchApp)
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

                    #if DEBUG
                    if CommandLine.arguments.contains("-seedDemoData") {
                        seedDemoData()
                    }
                    if CommandLine.arguments.contains("-showOnboarding") {
                        hasSeenOnboarding = false
                    }
                    if CommandLine.arguments.contains("-showICloudMigration") {
                        hasSeenOnboarding = true
                        iCloudMigrationComplete = false
                    }
                    #endif
                }
        }
    }

    #if DEBUG
    private func seedDemoData() {
        // Set flags so we skip onboarding and migration, going straight to MainScreen
        hasSeenOnboarding = true
        iCloudMigrationComplete = true

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
