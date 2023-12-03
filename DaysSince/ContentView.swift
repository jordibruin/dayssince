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

    @AppStorage("items", store: UserDefaults(suiteName: "group.goodsnooze.dayssince")) var items: [DSItem] = []

    @AppStorage("isDaysDisplayModeDetailed") var isDaysDisplayModeDetailed: Bool = false

    @Default(.categories) var categories
    @Default(.mainColor) var mainColor
    @Default(.backgroundColor) var backgroundColor

    init() {
        WishKit.configure(with: "6443C4AA-4663-4A27-89E5-846598908A4E")
        WishKit.config.statusBadge = .show
        WishKit.theme.primaryColor = mainColor
    }

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
