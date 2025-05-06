//
//  FirstEventPreview.swift
//  DaysSince
//
//  Created by Victoria Petrova on 06/05/2025.
//

import SwiftUI
struct FirstEventPreview: View {
    @AppStorage("items", store: UserDefaults(suiteName: "group.goodsnooze.dayssince"))
    private var storedItems: [DSItem] = []

    private var injectedItems: [DSItem]?

    var latestItem: DSItem? {
        (injectedItems ?? storedItems).last
    }
    
    let navigate: (OnboardingScreen) -> Void
    @State var counter: Int = 0
    @State var origin: CGPoint = .zero
    
    // Dummy data
    @State private var editItemSheet = false
    @State private var tappedItem: DSItem = DSItem.placeholderItem()
    @State private var isDaysDisplayModeDetailed = false
    @State private var items: [DSItem] = []
    
    init(items: [DSItem]? = nil, navigate: @escaping (OnboardingScreen) -> Void) {
        self.injectedItems = items
        self.navigate = navigate
    }

    var body: some View {
        VStack(spacing: 32) {
            ProgressBar(progress: 5/8)
                .padding(.horizontal)

            if let item = latestItem {
                DSItemView(
                    editItemSheet: $editItemSheet,
                    tappedItem: $tappedItem,
                    isDaysDisplayModeDetailed: $isDaysDisplayModeDetailed,
                    itemID: item.id,
                    items: $items,
                    colored: false
                )
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal)
            }

            ZStack {
                // Sunny on the right, anchored
                HStack {
                    Spacer()
                    Image("sunny-noracket")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 320)
                        .offset(x: 150, y: 60)
                        .rotationEffect(Angle(degrees: -30))
                        .modifier(RippleEffect(at: origin, trigger: counter))
                        .onAppear {
                            origin = .zero
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                counter += 1
                            }
                        }
                        .onTapGesture { location in
                            origin = location
                            counter += 1
                        }
                }

                HStack {
                    // Centered chat bubble
                    ChatBubble(direction: .right) {
                        Text("Congrats! You created your first event!")
                            .padding(20)
                            .foregroundColor(.primary)
                            .background(Color(.secondarySystemFill))
                    }
                    .frame(maxWidth: 220)
                    Spacer()
                }
            }
            .frame(maxHeight: .infinity) // push to middle space
            .padding(.horizontal)

            CustomButton(
                action: {},
                label: "Yay!",
                color: .animalCrossingsGreen
            )
            .padding(.horizontal)
            .padding(.bottom)
        }
        .padding(.top)
        .onAppear {
            items = injectedItems ?? storedItems
            if let last = items.last {
                tappedItem = last
            }
        }
    }

}


#Preview {
    FirstEventPreviewPreviewWrapper()
}


private struct FirstEventPreviewPreviewWrapper: View {
    static var mock: DSItem {
       DSItem(
           id: UUID(),
           name: "Pension",
           category: Category.placeholderCategory(),
           dateLastDone: Calendar.current.date(byAdding: .day, value: -25, to: Date()) ?? Date(),
           remindersEnabled: true,
           reminder: .monthly
       )
   }
    @State private var items: [DSItem] = [mock]

    var body: some View {
        FirstEventPreview(items: items, navigate: { _ in })
    }
}
