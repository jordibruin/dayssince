//
//  DaysSinceApp.swift
//  DaysSince
//
//  Created by Vicki Minerva on 3/28/22.
//

import SwiftUI

@main
struct DaysSinceApp: App {
    
    @StateObject var notificationManager = NotificationManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(notificationManager)
        }
    }
}
