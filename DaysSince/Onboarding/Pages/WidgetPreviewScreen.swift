//
//  WidgetPreviewScreen.swift
//  DaysSince
//
//  Created by Victoria Petrova on 06/05/2025.
//

import SwiftUI

struct WidgetPreviewScreen: View {
    @AppStorage("items", store: UserDefaults(suiteName: "group.goodsnooze.dayssince"))
    private var storedItems: [DSItem] = []
    private var injectedItems: [DSItem]?
    @State private var items: [DSItem] = []

    var latestEvent: DSItem {
        (injectedItems ?? storedItems).last ?? DSItem(id: UUID(), name: "Test", category: Category.placeholderCategory(), dateLastDone: Date.now, remindersEnabled: false)
    }
    

    var body: some View {
        ScrollView {
            ProgressBar(progress: 6/8)
                .padding(.horizontal)

            Text("Wanna keep it close?")
                .font(.system(.title2, design: .rounded))
                .bold()
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding([.horizontal, .top])

            Text("Add a widget to your home or lock screen and see your event at a glance.")
                .font(.system(.body, design: .rounded))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)

            widgetPreviews

            Color(.clear)
                .frame(height: 20)
                .padding(.vertical, 1)
        }
        .padding(.vertical)
        .onAppear {
            items = injectedItems ?? storedItems
        }
        CustomButton(action: {
            // move to next screen
        }, label: "Looks great!", color: .workColor)
        .padding(.horizontal)
        .padding(.vertical, 0)
    }

    var widgetPreviews: some View {
        VStack(spacing: 8) {
            Text("Lock screen widgets")
                .font(.system(.body, design: .rounded))
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.horizontal)
            
            // Accessory widget
            HStack(spacing: 12) {
                EventRectangularWidgetMock(event: EventCardModel(from: latestEvent))
                EventCircularWidgetMock(event: EventCardModel(from: latestEvent))
            }
            
            Text("Home screen widgets")
                .font(.system(.body, design: .rounded))
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.horizontal)
            
            // Small widget
            HStack(spacing: 12) {
                CompactEventCardView(event: EventCardModel(from: latestEvent))
                    .aspectRatio(1.0, contentMode: .fit)
                    .shadow(radius: 5, x: 1, y: 2)
                CompactEventCardView(event: EventCardModel(from: latestEvent))
                    .aspectRatio(1.0, contentMode: .fit)
                    .shadow(radius: 5, x: 1, y: 2)
                
            }
            .padding(.all, 8)

            // Medium simulations
            VStack(spacing: 12) {
                MediumWidgetMultiEvent(entry:[ EventCardModel(from: latestEvent), EventCardModel(from: latestEvent)])
                    .frame(height: 160)
                    .shadow(radius: 5, x: 1, y: 2)
                    .padding(.all, 8)
            }
            
        }
        .padding(.top, 8)
    }

}

#Preview {
    WidgetPreviewScreenWrapper()
}

private struct WidgetPreviewScreenWrapper: View {
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
        WidgetPreviewScreen()
    }
}


struct MediumWidgetMultiEvent: View {
    @Environment(\.colorScheme) var colorScheme

    let isDaysDisplayModeDetailed: Bool = true
    
    let entry: [EventCardModel]

    private var backgroundColor: Color {
        entry.first?.color.lighter(by: 0.04) ?? Color(.systemBackground)
    }
    
    private var borderColor: Color {
        if let firstEvent = entry.first {
            return colorScheme == .dark ? firstEvent.color.darker() : firstEvent.color
        } else {
            return .black
        }
    }

    var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .leading, spacing: 2) {
                // Iterate over all available events (up to 5), removing the prefix limit
                ForEach(entry) { event in
                    itemContent(for: event)
                }
            }
//            .aspectRatio(contentMode: .fit)
            .padding()
            .padding(.bottom, 6)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(colorScheme == .dark ? backgroundColor : Color.white)
            
        }
        .clipShape(RoundedRectangle(cornerRadius: 23))
        .overlay(
            RoundedRectangle(cornerRadius: 23)
                .stroke(borderColor, lineWidth: 6)
        )
        .shadow(color: Color.black.opacity(0.05), radius: 20, x: 0, y: 0)
    }
    
    @ViewBuilder
    func itemContent(for event: EventCardModel) -> some View {
        
        HStack(alignment: .center) {
            nameText(for: event)
                .minimumScaleFactor(0.2)
            
            Spacer()
            
            if event.name != "No events" {
                daysAgoText(for: event)
            }
        }
        
    }
    
    func nameText(for event: EventCardModel) -> some View {
        Text(event.name)
            .font(.system(.headline, design: .rounded))
            .bold()
            .foregroundColor(colorScheme == .dark ? .primary : event.color)
            .lineLimit(2)
            .minimumScaleFactor(0.6) // Text fits in widget
    }
    
    @ViewBuilder
    func daysAgoText(for event: EventCardModel) -> some View {
        if isDaysDisplayModeDetailed {
            detailedTimeView(for: event)
        } else {
            timeUnitView(value: event.daysNumber, unit: "days", color: event.color)
                .frame(width: event.daysNumber > 999 ? 60 : event.daysNumber > 99 ? 45 : 35)
            
        }
    }
    
    @ViewBuilder
    func detailedTimeView(for event: EventCardModel) -> some View {
        let currentDate = Date()
        let calendar = Calendar.current

        let dateComponents = calendar.dateComponents([.year, .month, .day], from: calendar.startOfDay(for: event.dateLastDone), to: calendar.startOfDay(for: currentDate))

        let years = dateComponents.year ?? 0
        let months = dateComponents.month ?? 0
        let days = dateComponents.day ?? 0
        
        HStack(alignment: .top, spacing: 6) {
            if years > 0 {
                timeUnitView(value: years, unit: years == 1 ? "year" : "years", color: event.color)
            }

            if months > 0 || years > 0 {
                timeUnitView(value: months, unit: months == 1 ? "month" : "months", color: event.color)
            }

           
            timeUnitView(value: days, unit: days == 1 ? "day" : "days", color: event.color)
            
        }
    }
    
    private func timeUnitView(value: Int, unit: String, color: Color) -> some View {
        VStack(alignment: .center, spacing: 0) {
            Text("\(value)")
                .font(.system(.title2, design: .rounded))
                .bold()
                .minimumScaleFactor(0.7)
                .foregroundColor(colorScheme == .dark ? .primary : color)
                .lineLimit(1)

            Text(unit)
                .font(.system(.caption, design: .rounded))
                .minimumScaleFactor(0.4)
                .foregroundColor(colorScheme == .dark ? .primary : color)
                .lineLimit(1)
        }
    }
}


struct EventCircularWidgetMock: View {
    var event: EventCardModel

    var body: some View {
        ZStack {
            Circle()
                .fill(.ultraThinMaterial)
                .frame(width: 60, height: 60)

            VStack(spacing: 2) {
                if event.name == "No event" {
                    Text("Tap")
                        .font(.caption2)
                    Text("to set")
                        .font(.caption2)
                } else {
                    Text("\(event.daysNumber)")
                        .font(.system(.title2, design: .rounded))
                        .bold()
                    Text(event.daysNumber == 1 ? "day" : "days")
                        .font(.caption2)
                        .fontDesign(.rounded)
                }
            }
            .multilineTextAlignment(.center)
        }
        .frame(width: 80, height: 80)
    }
}


struct EventRectangularWidgetMock: View {
    var event: EventCardModel

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
                .frame(height: 60)

            HStack {
                if event.name == "No event" {
                    Text("Tap to select event!")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                } else {
                    Text(event.name)
                        .font(.system(.headline, design: .rounded))
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)

                    Spacer()

                    VStack(spacing: 2) {
                        Text("\(event.daysNumber)")
                            .font(.headline)
                            .bold()
                            .fontDesign(.rounded)
                        Text(event.daysNumber == 1 ? "day" : "days")
                            .font(.caption2)
                            .fontDesign(.rounded)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(.horizontal, 12)
        }
        .frame(width: 160, height: 60)
    }
}

