//
//  Widget.swift
//  Widget
//
//  Created by Jordi Bruin on 27/06/2022.
//

import Defaults
import SwiftUI
import WidgetKit


// MARK: - Single Event Widget

struct SingleEventWidget: Widget {
    let kind: String = "SingleEventWidget"

    public var body: some WidgetConfiguration {
        IntentConfiguration(
            kind: kind,
            intent: SelectEventIntent.self,
            provider: Provider()
        ) { entry in
            EventCardWidgetView(event: entry)
        }
        .configurationDisplayName(LocalizedStringKey("widget.singleEvent.title"))
        .description(LocalizedStringKey("widget.singleEvent.explanation"))
        .supportedFamilies([.systemSmall, .systemMedium, .accessoryCircular, .accessoryInline, .accessoryRectangular])
        .contentMarginsDisabled() // iOS17 widgets force additional margin padding on your design
    }
}



// MARK: - Multi Event Widget

// Define the data structure for the multi-event widget
struct MultipleEventsEntry: TimelineEntry {
    let date: Date
    let events: [WidgetContent] // Store up to 5 events

    // Helper to create placeholder data (show up to 5)
    static func placeholder() -> MultipleEventsEntry {
        let placeholderEvent = WidgetContent(date: Date(), name: "Placeholder Event", id: UUID(), color: .gray, daysNumber: 0)
        // Adjust placeholder count if needed for different widget sizes
        return MultipleEventsEntry(date: Date(), events: Array(repeating: placeholderEvent, count: 5))
    }
    
    // Helper to create snapshot data (show up to 5 realistic examples)
    static func snapshot() -> MultipleEventsEntry {
        let event1 = WidgetContent(date: Calendar.current.date(byAdding: .day, value: -403, to: Date())!, name: "📲 New phone", id: UUID(), color: .workColor, daysNumber: 403)
        let event2 = WidgetContent(date: Calendar.current.date(byAdding: .day, value: -4, to: Date())!, name: "💇‍♀️ Haircut", id: UUID(), color: .healthColor, daysNumber: 4)
        let event3 = WidgetContent(date: Calendar.current.date(byAdding: .day, value: -14, to: Date())!, name: "💅 Nails", id: UUID(), color: .hobbiesColor, daysNumber: 14)
        let event4 = WidgetContent(date: Calendar.current.date(byAdding: .day, value: -94, to: Date())!, name: "📆 Project Deadline", id: UUID(), color: .workColor, daysNumber: 94)
        let event5 = WidgetContent(date: Calendar.current.date(byAdding: .day, value: -2, to: Date())!, name: "🌴 Vacation Start", id: UUID(), color: .zeldaYellow, daysNumber: 2)
         // Show a representative number for the snapshot, e.g., 3-5
         return MultipleEventsEntry(date: Date(), events: [event1, event2, event4, event5])
    }
}


// Define the new multi-event widget configuration
struct MultipleEventsWidget: Widget {
    let kind: String = "MultipleEventsWidget"

    var body: some WidgetConfiguration {
        IntentConfiguration(
            kind: kind,
            intent: SelectMultipleEventsIntent.self,
            provider: MultipleEventsProvider()
        ) { entry in
            MultipleEventsWidgetView(entry: entry)
        }
        .configurationDisplayName(LocalizedStringKey("widget.multiEvent.title"))
        .description(LocalizedStringKey("widget.multiEvent.explanation"))
        .supportedFamilies([.systemMedium, .systemLarge])
        .contentMarginsDisabled()
    }
}

// MARK: - Widget Bundle
@main
struct DaysSinceWidgetsBundle: WidgetBundle {
    var body: some Widget {
        SingleEventWidget()
        MultipleEventsWidget() 
    }
}

// Widgets changed with iOS 17
// A hot fix for this so it still works on iOS16 devices
extension View {
    func widgetBackground(_ backgroundView: some View) -> some View {
        if #available(iOSApplicationExtension 17.0, *) {
            return containerBackground(for: .widget) {
                backgroundView
            }
        } else {
            return background(backgroundView)
        }
    }
}
