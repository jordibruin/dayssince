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
                Group {
                    switch screen {
                    case .screen2:
                        CategoryPage(navigate: navigate)
                    case .screen3(let selectedCategories):
                        PickFirstEventPage(selectedCategories: selectedCategories, navigate: navigate)
                    case .screen4(let initialEventName):
                        CreateFirstEvent(initialEventName: initialEventName, navigate: navigate)
                    case .screen5:
                        FirstEventPreview(navigate: navigate)
                    case .screen6:
                        WidgetPreviewScreen(navigate: navigate)
                    case .screen7:
                        FeaturesPage(navigate: navigate)
                    case .screen8:
                        LastPage(navigate: navigate)
                    }
                }
                .navigationBarBackButtonHidden(true)
            }
        }
    }

    func navigate(to screen: OnboardingScreen) {
        path.append(screen)
    }
}

enum OnboardingScreen: Hashable {
    case screen2
    case screen3(selectedCategories: [Category])
    case screen4(initialEventName: String)
    case screen5
    case screen6
    case screen7
    case screen8
    // Add more if needed
}



#Preview {
    OnboardingRootView()
}
