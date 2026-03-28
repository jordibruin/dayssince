//
//  MultipleEventsWidgetView.swift
//  WidgetExtension
//
//  Created by Victoria Petrova on 07/04/2025.
//

import SwiftUI
import WidgetKit

struct MultipleEventsWidgetView: View {
    let entry: MultipleEventsEntry
    @Environment(\.widgetFamily) var family
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.widgetRenderingMode) var renderingMode

    @AppStorage("isDaysDisplayModeDetailed", store: UserDefaults(suiteName: "group.goodsnooze.dayssince")) var isDaysDisplayModeDetailed: Bool = true
    @AppStorage("dayssince_subscribed", store: UserDefaults(suiteName: "group.goodsnooze.dayssince")) var isSubscribed: Bool = false

    private var backgroundColor: Color {
        entry.events.first?.color.lighter(by: 0.04) ?? Color(.systemBackground)
    }
    
    private var borderColor: Color {
        if let firstEvent = entry.events.first {
            return colorScheme == .dark ? firstEvent.color.darker() : firstEvent.color
        } else {
            return .black
        }
    }

    var body: some View {
        if !isSubscribed {
            WidgetLockedView()
        } else {
            mainContent
        }
    }

    private var mainContent: some View {
        GeometryReader { geometry in
            VStack(alignment: .leading, spacing: 2) {
                // Iterate over all available events (up to 5), removing the prefix limit
                ForEach(entry.events) { event in
                    itemContent(for: event)
                }
            }
            .padding()
            .padding(.bottom, 6)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background {
                if colorScheme == .dark && renderingMode == .fullColor {
                    backgroundColor
                } else {
                    Color.clear.luminanceToAlpha()
                }
            }
        }
        .clipShape(ContainerRelativeShape())
        .overlay(
            Group {
                if renderingMode == .fullColor {
                    ContainerRelativeShape()
                        .strokeBorder(borderColor, lineWidth: 4)
                } else {
                    ContainerRelativeShape()
                        .strokeBorder(borderColor, lineWidth: 4)
                        .luminanceToAlpha()
                }
            }
        )
        .background(ContainerRelativeShape().fill(Color.clear))
        .containerBackground(for: .widget) { Color.clear }
        .widgetAccentable()
    }
    
    @ViewBuilder
    func itemContent(for event: WidgetContent) -> some View {
        
        HStack(alignment: .center) {
            nameText(for: event)
                .minimumScaleFactor(0.2)
            
            Spacer()
            
            if event.name != "No events" {
                daysAgoText(for: event)
            }
        }
        
    }
    
    func nameText(for event: WidgetContent) -> some View {
        Text(event.name)
            .font(.system(.headline, design: .rounded))
            .bold()
            .foregroundColor(colorScheme == .dark ? .primary : event.color)
            .lineLimit(2)
            .minimumScaleFactor(0.6) // Text fits in widget
    }
    
    @ViewBuilder
    func daysAgoText(for event: WidgetContent) -> some View {
        if isDaysDisplayModeDetailed {
            detailedTimeView(for: event)
        } else {
            timeUnitView(value: event.daysNumber, unit: "days", color: event.color)
                .frame(width: event.daysNumber > 999 ? 60 : event.daysNumber > 99 ? 45 : 35)
            
        }
    }
    
    @ViewBuilder
    func detailedTimeView(for event: WidgetContent) -> some View {
        let currentDate = Date()
        let calendar = Calendar.current

        let dateComponents = calendar.dateComponents([.year, .month, .day], from: calendar.startOfDay(for: event.date), to: calendar.startOfDay(for: currentDate))

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
//            .padding(.trailing, 0)
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

struct MultipleEventsWidgetView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            MultipleEventsWidgetView(entry: MultipleEventsEntry.snapshot())
                .previewContext(WidgetPreviewContext(family: .systemMedium))
                .previewDisplayName("Medium Widget")
            
            MultipleEventsWidgetView(entry: MultipleEventsEntry.snapshot())
                .previewContext(WidgetPreviewContext(family: .systemLarge))
                .previewDisplayName("Large Widget (Dark)")
                .environment(\.colorScheme, .dark)
        }
    }
}
