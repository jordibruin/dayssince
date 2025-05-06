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
                case .screen4(let initialEventName):
                    CreateFirstEvent(initialEventName: initialEventName, navigate: navigate)
                case .screen5:
                    FirstEventPreview(navigate: navigate)
                }
            }
        }
    }

    func navigate(to screen: OnboardingScreen) {
        path.append(screen)
    }
}

enum OnboardingScreen: Hashable {
    case screen2
    case screen3
    case screen4(initialEventName: String)
    case screen5
    // Add more if needed
}



#Preview {
    OnboardingRootView()
}
