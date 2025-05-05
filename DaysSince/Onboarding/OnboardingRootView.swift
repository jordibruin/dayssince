//
//  OnboardingRootView.swift
//  DaysSince
//
//  Created by Victoria Petrova on 04/05/2025.
//

import SwiftUI

struct OnboardingRootView: View {
    @State private var path: [OnboardingScreen] = []

    var body: some View {
        NavigationStack(path: $path) {
            IntroPage(navigate: { screen in
                path.append(screen)
            })
            .navigationDestination(for: OnboardingScreen.self) { screen in
                switch screen {
                case .screen2:
                    CategoryPage(navigate: navigate)
                case .screen3:
                    PickFirstEventPage(navigate: navigate)
                // Add other screens...
                }
            }
        }
    }

    func navigate(to screen: OnboardingScreen) {
        path.append(screen)
    }
}

enum OnboardingScreen: Hashable {
    case screen2, screen3//, screen4, screen5, screen6, screen7, screen8
}


#Preview {
    OnboardingRootView()
}
