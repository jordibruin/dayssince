//
//  DaysSinceApp.swift
//  DaysSince
//
//  Created by Vicki Minerva on 3/28/22.
//

import Defaults
import SwiftUI
import WidgetKit

@main
struct DaysSinceApp: App {
    @StateObject var notificationManager = NotificationManager()
    @StateObject var categoryManager = CategoryManager()
    @StateObject var reviewManager: ReviewManager
    
    init() {
        let reviewManager = ReviewManager()
        _reviewManager = StateObject(wrappedValue: reviewManager)
    }

    @Environment(\.scenePhase) var scenePhase

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(notificationManager)
                .environmentObject(categoryManager)
                .environmentObject(reviewManager)
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
