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
    @StateObject var notificationManager = NotificationManager()
    @StateObject var categoryManager = CategoryManager()
    @StateObject var reviewManager: ReviewManager
    @StateObject var store = StoreManager()
    @StateObject private var entitlements: Entitlements
    
    init() {
        let reviewManager = ReviewManager()
        _reviewManager = StateObject(wrappedValue: reviewManager)
        let store = StoreManager()
        _store = StateObject(wrappedValue: store)
        _entitlements = StateObject(wrappedValue: Entitlements(store: store))
        
        let config = TelemetryDeck.Config(appID: "FBE58244-22B0-4207-9ED7-052DEB5B8A26")
        config.defaultSignalPrefix = "DaysSince."
        config.testMode = isSimulatorOrTestFlight()
        TelemetryDeck.initialize(config: config)
//        Analytics.send(.launchApp)
    }

    @Environment(\.scenePhase) var scenePhase

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(notificationManager)
                .environmentObject(categoryManager)
                .environmentObject(reviewManager)
                .environmentObject(store)
                .environmentObject(entitlements)
                .onChange(of: self.scenePhase) {
                    switch $0 {
                    case .background:
                        WidgetCenter.shared.reloadAllTimelines()
                    default: break
                    }
                }
        }
    }
}
