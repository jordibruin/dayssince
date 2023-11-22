//
//  ContentView.swift
//  DaysSince
//
//  Created by Vicki Minerva on 3/28/22.
//

import Defaults
import SwiftUI

struct ContentView: View {
    @AppStorage("hasSeenOnboarding") var hasSeenOnboarding: Bool = false

    @AppStorage("items", store: UserDefaults(suiteName: "group.goodsnooze.dayssince")) var items: [DSItem] = []

    @AppStorage("isDaysDisplayModeDetailed") var isDaysDisplayModeDetailed: Bool = false

    @Default(.categories) var categories
    @Default(.mainColor) var mainColor
    @Default(.backgroundColor) var backgroundColor

    var body: some View {
        if hasSeenOnboarding {
            MainScreen(items: $items,
                       isDaysDisplayModeDetailed: $isDaysDisplayModeDetailed)
        } else {
            OnboardingScreen(hasSeenOnboarding: $hasSeenOnboarding, items: $items)
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
