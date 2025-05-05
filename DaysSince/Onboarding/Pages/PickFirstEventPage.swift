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
    
    let navigate: (OnboardingScreen) -> Void
    private static let gridLayout = Array(
        repeating: GridItem(.flexible(minimum: 100), spacing: 10),
        count: 2
    )
    
    private static let eventOptions: [EventCardModel] = [
        .init(id: UUID(), dateLastDone: Calendar.daysAgo(37), name: "✂️ Haircut", color: .animalCrossingsGreen),
        .init(id: UUID(), dateLastDone: Calendar.daysAgo(17), name: "🐾 Cat litter", color: .hobbiesColor),
        .init(id: UUID(), dateLastDone: Calendar.daysAgo(1), name: "🏃‍♂️ Work out", color: .marioBlue),
        .init(id: UUID(), dateLastDone: Calendar.daysAgo(5), name: "🧹 Vacuum", color: .workColor),
        .init(id: UUID(), dateLastDone: Calendar.daysAgo(25*365+2*30+13), name: "🐣 I was born", color: .marioRed),
        .init(id: UUID(), dateLastDone: Calendar.daysAgo(3), name: "👯 Hung out with friends", color: .lifeColor)
    ]
    
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
            ForEach(Self.eventOptions) { event in
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
//        navigate(.screen4)
    }
}

#Preview {
    PickFirstEventPage { _ in
    }
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

