//
//  DaysSinceApp.swift
//  DaysSince
//
//  Created by Vicki Minerva on 3/28/22.
//

import SwiftUI
import WidgetKit

@main
struct DaysSinceApp: App {
    @StateObject var notificationManager = NotificationManager()

    @Environment(\.scenePhase) var scenePhase

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(notificationManager)
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
