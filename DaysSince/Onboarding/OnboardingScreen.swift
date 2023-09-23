//
//  OnboardingScreen.swift
//  DaysSince
//
//  Created by Vicki Minerva on 7/13/22.
//

import SwiftUI

struct OnboardingScreen: View {
    @Binding var hasSeenOnboarding: Bool
    @Binding var items: [DSItem]

    @State var selectedPage = 0

    var body: some View {
        TabView(selection: $selectedPage) {
            Introduction(selectedPage: $selectedPage).tag(0)
                .simultaneousGesture(DragGesture())

            CreateFirstEvent(hasSeenOnboarding: $hasSeenOnboarding, selectedPage: $selectedPage, items: $items).tag(1)
                .simultaneousGesture(DragGesture())

//            PurchasesView(inOnboarding: true, selectedPage: $selectedPage).tag(2)
//                .clipped()
//                .simultaneousGesture(DragGesture())
//
//            Settings().tag(3)
//                .simultaneousGesture(DragGesture())
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .interactiveDismissDisabled()
        .edgesIgnoringSafeArea(.all)
//        .statusBarStyle(.lightContent)
    }
}

struct OnboardingScreen_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingScreen(hasSeenOnboarding: .constant(false), items: .constant([]))
    }
}
