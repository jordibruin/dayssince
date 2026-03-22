//
//  PickFirstEventPage.swift
//  DaysSince
//
//  Created by Victoria Petrova on 04/05/2025.
//

import SwiftUI

struct PickFirstEventPage: View {
    @State private var selectedEvent: EventCardModel?
    @State private var tappedEvent: EventCardModel?

    let selectedCategories: [Category]
    let navigate: (OnboardingScreen) -> Void
    private static let gridLayout = Array(
        repeating: GridItem(.flexible(minimum: 100), spacing: 10),
        count: 2
    )

    /// Maps category names to suggested events for that category
    private static let eventsByCategory: [String: [EventCardModel]] = [
        "Work": [
            .init(dateLastDone: Calendar.daysAgo(30), name: "📊 Performance review", color: .workColor),
            .init(dateLastDone: Calendar.daysAgo(90), name: "💼 Resume update", color: .workColor)
        ],
        "Life": [
            .init(dateLastDone: Calendar.daysAgo(37), name: "✂️ Haircut", color: .lifeColor),
            .init(dateLastDone: Calendar.daysAgo(3), name: "👯 Hung out with friends", color: .lifeColor)
        ],
        "Hobby": [
            .init(dateLastDone: Calendar.daysAgo(1), name: "🏃‍♂️ Work out", color: .hobbiesColor),
            .init(dateLastDone: Calendar.daysAgo(7), name: "🎮 Game night", color: .hobbiesColor)
        ],
        "Health": [
            .init(dateLastDone: Calendar.daysAgo(180), name: "🏥 Dentist visit", color: .healthColor),
            .init(dateLastDone: Calendar.daysAgo(30), name: "💊 Vitamins refill", color: .healthColor)
        ],
        "Home": [
            .init(dateLastDone: Calendar.daysAgo(60), name: "💧 Water filter change", color: .marioBlue),
            .init(dateLastDone: Calendar.daysAgo(30), name: "⛽ Gas meter reading", color: .marioBlue)
        ],
        "Pet": [
            .init(dateLastDone: Calendar.daysAgo(17), name: "🐾 Cat litter", color: .animalCrossingsBrown),
            .init(dateLastDone: Calendar.daysAgo(365), name: "💉 Dog vaccination", color: .animalCrossingsBrown)
        ],
        "Friends": [
            .init(dateLastDone: Calendar.daysAgo(3), name: "👯 Hung out with friends", color: .animalCrossingsGreen),
            .init(dateLastDone: Calendar.daysAgo(14), name: "🎁 Birthday gift", color: .animalCrossingsGreen)
        ],
        "Projects": [
            .init(dateLastDone: Calendar.daysAgo(7), name: "🔨 Side project update", color: .zeldaYellow),
            .init(dateLastDone: Calendar.daysAgo(30), name: "📝 Blog post", color: .zeldaYellow)
        ],
        "Journal": [
            .init(dateLastDone: Calendar.daysAgo(1), name: "📓 Journaled", color: .marioRed),
            .init(dateLastDone: Calendar.daysAgo(2), name: "🧘 Meditation", color: .marioRed)
        ]
    ]

    private var eventOptions: [EventCardModel] {
        selectedCategories.flatMap { category in
            Self.eventsByCategory[category.name] ?? []
        }
    }
    
    var body: some View {
        VStack {
            ProgressBar(progress: 3/8)
                .padding()
            
            header
            
            ScrollView {
                eventGrid
            }
            
            Spacer()
        }
        
        CustomButton(action: nextPage, label: "Continue", color: .animalCrossingsGreen)
            .opacity(selectedEvent == nil ? 0.4 : 1.0)
            .disabled(selectedEvent == nil)
    }
    
    private var header: some View {
        VStack(alignment: .leading) {
            Text("What event do you want to keep track of?")
                .font(.system(.title3, design: .rounded))
                .bold()
            
            Text("Pick one. You can edit it or create more events later. ")
                .font(.system(.footnote, design: .rounded))
        }
    }
    
    private var eventGrid: some View {
        LazyVGrid(columns: Self.gridLayout, spacing: 12) {
            ForEach(eventOptions) { event in
                EventSelectionView(
                    model: event,
                    isSelected: selectedEvent?.id == event.id,
                    isTapped: tappedEvent?.id == event.id,
                    onTap: { handleEventTap(event) }
                )
            }
        }
        .padding(.all)
    }
    
    private func handleEventTap(_ event: EventCardModel) {
        tappedEvent = event
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            tappedEvent = nil
        }
        toggleSelection(of: event)
    }
    
    private func toggleSelection(of event: EventCardModel) {
        if selectedEvent?.id == event.id {
            selectedEvent = nil
        } else {
            selectedEvent = event
        }
    }
    
    private func nextPage() {
        print("next page")
        // Find which category the selected event belongs to
        let matchedCategory: Category? = selectedEvent.flatMap { event in
            selectedCategories.first { category in
                Self.eventsByCategory[category.name]?.contains(where: { $0.id == event.id }) == true
            }
        }
        navigate(.screen4(initialEventName: selectedEvent?.name ?? " ", initialCategory: matchedCategory))
    }
}

#Preview {
    PickFirstEventPage(selectedCategories: [
        Category(stableID: Category.stableIDPet, name: "Pet", emoji: "dog", color: .animalCrossingsBrown),
        Category(stableID: Category.stableIDHome, name: "Home", emoji: "house", color: .marioBlue)
    ]) { _ in }
}

struct EventSelectionView: View {
    let model: EventCardModel
    let isSelected: Bool
    let isTapped: Bool
    let onTap: () -> Void

    var body: some View {
        CompactEventCardView(event: model)
            .scaleEffect(isTapped ? 0.98 : 1.0)
            .animation(.spring(response: 0.2, dampingFraction: 0.3), value: isTapped)
            .overlay(alignment: .topTrailing) {
                Image(systemName: "checkmark.circle.fill")
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(.white, .blue)
                    .font(.title3)
                    .padding(8)
                    .shadow(color: .blue.opacity(0.1), radius: 5)
                    .opacity(isSelected ? 1.0 : 0.0)
            }
            .aspectRatio(1.0, contentMode: .fit)
            .onTapGesture(perform: onTap)
    }
}

