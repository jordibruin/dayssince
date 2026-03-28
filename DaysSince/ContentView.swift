//
//  ContentView.swift
//  DaysSince
//
//  Created by Vicki Minerva on 3/28/22.
//

import Defaults
import SwiftUI
import WishKit

struct ContentView: View {
    @AppStorage("hasSeenOnboarding") var hasSeenOnboarding: Bool = false
    @AppStorage("iCloudMigrationComplete") var iCloudMigrationComplete: Bool = false
    @AppStorage("migratedFromOld") var migratedFromOld: Bool = false
    @AppStorage("hasSeenPaywall") var hasSeenPaywall: Bool = false

    // Keep oldItems for legacy migration only
    @AppStorage("items", store: UserDefaults(suiteName: "group.goodsnooze.dayssince")) var oldItems: [oldDSItem] = []

    @AppStorage("isDaysDisplayModeDetailed", store: UserDefaults(suiteName: "group.goodsnooze.dayssince")) var isDaysDisplayModeDetailed: Bool = true

    @EnvironmentObject var dataSyncManager: DataSyncManager
    @EnvironmentObject var subscriptionManager: SubscriptionManager

    @Default(.categories) var categories
    @Default(.mainColor) var mainColor
    @Default(.backgroundColor) var backgroundColor

    @State private var showPaywallSheet = false
    @State private var justFinishedOnboarding = false

    init() {
        WishKit.configure(with: "6443C4AA-4663-4A27-89E5-846598908A4E")
        WishKit.config.statusBadge = .show
    }

    /// Binding that reads/writes items through DataSyncManager.
    private var itemsBinding: Binding<[DSItem]> {
        Binding(
            get: { dataSyncManager.items },
            set: { dataSyncManager.saveItems($0) }
        )
    }

    var body: some View {
        if hasSeenOnboarding {
            if !iCloudMigrationComplete {
                // State B: Existing user, first launch after iCloud update
                iCloudMigrationView(iCloudMigrationComplete: $iCloudMigrationComplete)
            } else {
                MainScreen(items: itemsBinding,
                           isDaysDisplayModeDetailed: $isDaysDisplayModeDetailed)
                    .onAppear {
                        WishKit.theme.primaryColor = mainColor

                        // Legacy migration from old item format
                        if !migratedFromOld {
                            if !oldItems.isEmpty {
                                let newItems = oldItems.map { oldItem in
                                    DSItem(
                                        id: oldItem.id,
                                        name: oldItem.name,
                                        category: Category.placeholderCategory(),
                                        dateLastDone: oldItem.dateLastDone,
                                        remindersEnabled: oldItem.remindersEnabled,
                                        reminder: oldItem.reminder,
                                        reminderNotificationID: oldItem.reminderNotificationID
                                    )
                                }
                                dataSyncManager.saveItems(dataSyncManager.items + newItems)
                                migratedFromOld = true
                            }
                        }

                        // Show paywall once for all users
                        if !hasSeenPaywall {
                            showPaywallSheet = true
                            hasSeenPaywall = true
                        }
                    }
                    .sheet(isPresented: $showPaywallSheet) {
                        PaywallScreen(isDismissable: !justFinishedOnboarding)
                    }
            }
        } else {
            OnboardingRootView()
                .onDisappear {
                    // When onboarding finishes, reload items from AppGroup
                    // (onboarding writes items directly to AppStorage)
                    dataSyncManager.reloadFromAppGroup()
                    // Mark iCloud migration as complete for new users
                    iCloudMigrationComplete = true
                    justFinishedOnboarding = true
                }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView()
        }
    }
}
