//
//  MultipleEventsWidgetView.swift
//  WidgetExtension
//
//  Created by Victoria Petrova on 07/04/2025.
//

import SwiftUI

struct MultipleEventsWidgetView: View {
    let entry: MultipleEventsEntry
    @Environment(\.widgetFamily) var family
    @Environment(\.colorScheme) var colorScheme

    @AppStorage("isDaysDisplayModeDetailed", store: UserDefaults(suiteName: "group.goodsnooze.dayssince")) var isDaysDisplayModeDetailed: Bool = true

    
    // Determine background color based on scheme
    private var backgroundColor: Color {
        entry.events.first?.color.lighter(by: 0.04) ?? Color(.systemBackground)
    }

    // Determine text color based on scheme
//    private var primaryTextColor: Color {
//        colorScheme == .dark ? .white : .black
//    }
//
    private var borderColor: Color {
        if let firstEvent = entry.events.first {
            return colorScheme == .dark ? firstEvent.color.darker() : firstEvent.color
        } else {
            return .black
        }
    }

    var body: some View {
        ZStack(alignment: .leading) {
            if colorScheme == .dark {
                backgroundColor
            } else {
                Color.white
            }
            
            VStack(alignment: .leading, spacing: 2) { 
                // Iterate over all available events (up to 5), removing the prefix limit
                ForEach(entry.events) { event in
                    itemContent(for: event)
                    
//                    // Add divider logic, checking against last ID
//                    if event.id != entry.events.last?.id {
//                         Divider().background(borderColor.opacity(0.5))
//                    }
                }
//                Spacer() // Push content to top
            }
            .padding(4)
        }
        .clipShape(RoundedRectangle(cornerRadius: 23))
        .overlay(
            RoundedRectangle(cornerRadius: 23)
                .stroke(borderColor, lineWidth: 6)
        )
        .widgetBackground(Color.clear) // iOS 17 background handling
    }
    
    @ViewBuilder
    func itemContent(for event: WidgetContent) -> some View {
        
        HStack(alignment: .center) {
            nameText(for: event)
            
            Spacer()
            
            if event.name != "No events" {
                daysAgoText(for: event)
            }
        }
        
    }
    
    func nameText(for event: WidgetContent) -> some View {
        Text(event.name)
            .font(.system(.subheadline, design: .rounded))
            .bold()
            .foregroundColor(colorScheme == .dark ? .primary : event.color)
            .minimumScaleFactor(0.6) // Text fits in widget
    }
    
    @ViewBuilder
    func daysAgoText(for event: WidgetContent) -> some View {
        let currentDate = Date()
        let calendar = Calendar.current

        let dateComponents = calendar.dateComponents([.year, .month, .day], from: calendar.startOfDay(for: event.date), to: calendar.startOfDay(for: currentDate))

        let years = dateComponents.year ?? 0
        let months = dateComponents.month ?? 0
        let days = dateComponents.day ?? 0

        if isDaysDisplayModeDetailed {
            HStack(alignment: .top, spacing: 6) {
                if years > 0 {
                    VStack(alignment: .center) {
                        Text("\(years)")
                            .font(.system(.subheadline, design: .rounded))
                            .bold()
                            .foregroundColor(colorScheme == .dark ? .primary : event.color)

                        Text(years == 1 ? "year" : "years")
                            .font(.system(years > 9 || months > 9 ? .caption : .caption, design: .rounded))
                            .foregroundColor(colorScheme == .dark ? .primary : event.color)
                    }
                }

                if months > 0 || years > 0 {
                    VStack(alignment: .center) {
                        Text("\(months)")
                            .font(.system(.subheadline, design: .rounded))
                            .bold()
                            .foregroundColor(colorScheme == .dark ? .primary : event.color)

                        Text(months == 1 ? "month" : "months")
                            .font(.system(years > 0 ? .caption2 : .caption, design: .rounded))
                            .foregroundColor(colorScheme == .dark ? .primary : event.color)
                    }
                }

                VStack(alignment: .center) {
                    Text("\(days)")
                        .font(.system(.subheadline, design: .rounded))
                        .bold()
                        .foregroundColor(colorScheme == .dark ? .primary : event.color)

                    Text(days == 1 ? "day" : "days")
                        .font(.system(years > 0 ? .caption : .caption, design: .rounded))
                        .foregroundColor(colorScheme == .dark ? .primary : event.color)
                }
            }
            .padding(.trailing, 0)
        } else {
            VStack(alignment: .center) {
                Text("\(event.daysNumber)")
                    .font(.system(event.daysNumber > 9999 ? .title3 : .subheadline, design: .rounded))
                    .bold()
                    .foregroundColor(colorScheme == .dark ? .primary : event.color)

                Text("days")
                    .font(.system(.footnote, design: .rounded))
                    .foregroundColor(colorScheme == .dark ? .primary : event.color)
            }
            .frame(width: event.daysNumber > 999 ? 70 : event.daysNumber > 99 ? 50 : 40)
        }
    }
}

//#Preview {
//    MultipleEventsWidgetView()
//}
