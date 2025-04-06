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

struct Provider: IntentTimelineProvider {
    @AppStorage("items", store: UserDefaults(suiteName: "group.goodsnooze.dayssince")) var items: [DSItem] = []

//    var travelCardsManager = TravelCardsManager.shared

    func placeholder(in _: Context) -> WidgetContent {
        let content = WidgetContent(date: Date(), name: "Adopted Leo 🐱", id: UUID(), color: Color.lifeColor, daysNumber: 237)

        return content
    }

    public func getSnapshot(
        for _: SelectEventIntent,
        in _: Context,
        completion: @escaping (WidgetContent) -> Void
    ) {
        let content = WidgetContent(date: Date(), name: "Adopted Charlie 🐶", id: UUID(), color: .green, daysNumber: 45)
        completion(content)
    }

    public func getTimeline(
        for configuration: SelectEventIntent,
        in _: Context,
        completion: @escaping (Timeline<WidgetContent>) -> Void
    ) {
        let eventId = configuration.event?.identifier ?? ""

        if let matchingEvent = items.first(where: { $0.id.uuidString == eventId }) {
            let content = WidgetContent(item: matchingEvent)
            completion(Timeline(entries: [content], policy: .atEnd))
        } else {
            let content = WidgetContent(date: Date(), name: "No events", id: UUID(), color: .green, daysNumber: 4)
            completion(Timeline(entries: [content], policy: .atEnd))
        }
    }
}

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
        .supportedFamilies([.systemSmall, .systemMedium])
        .contentMarginsDisabled() // iOS17 widgets force additional margin padding on your design
    }
}

// Define the data structure for the single event widget
struct WidgetContent: TimelineEntry, Identifiable {
    var date: Date
    let name: String
    let id: UUID

    let color: Color
    let daysNumber: Int

    init(date: Date, name: String, id: UUID, color: Color, daysNumber: Int) {
        self.date = date
        self.name = name
        self.id = id
        self.color = color
        self.daysNumber = daysNumber
    }

    init(item: DSItem) {
        date = item.dateLastDone
        name = item.name
        id = item.id
        color = item.category.color.color

        let daysSince = Calendar.current.numberOfDaysBetween(item.dateLastDone, and: Date.now)
        daysNumber = abs(daysSince)
        
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
         let event1 = WidgetContent(date: Date(), name: " Apple SSC Results", id: UUID(), color: .blue, daysNumber: 8)
         let event2 = WidgetContent(date: Date(), name: "💇‍♀️ Haircut", id: UUID(), color: .cyan, daysNumber: 23)
         let event3 = WidgetContent(date: Date(), name: "💅 Nails", id: UUID(), color: .pink, daysNumber: 35)
         let event4 = WidgetContent(date: Date(), name: "📆 Project Deadline", id: UUID(), color: .orange, daysNumber: 50)
         let event5 = WidgetContent(date: Date(), name: "🌴 Vacation Start", id: UUID(), color: .purple, daysNumber: 70)
         // Show a representative number for the snapshot, e.g., 3-5
         return MultipleEventsEntry(date: Date(), events: [event1, event2, event3, event4, event5])
    }
}

// Define the provider for the multi-event widget
struct MultipleEventsProvider: IntentTimelineProvider {
    @AppStorage("items", store: UserDefaults(suiteName: "group.goodsnooze.dayssince")) var items: [DSItem] = []

    // Placeholder for context
    func placeholder(in context: Context) -> MultipleEventsEntry {
        // Adjust placeholder count based on family if needed
        MultipleEventsEntry.placeholder()
    }

    // Snapshot for widget gallery
    func getSnapshot(for configuration: SelectMultipleEventsIntent, in context: Context, completion: @escaping (MultipleEventsEntry) -> Void) {
        // Provide realistic snapshot data up to 5
        completion(MultipleEventsEntry.snapshot())
    }

    // Timeline generation
    func getTimeline(for configuration: SelectMultipleEventsIntent, in context: Context, completion: @escaping (Timeline<MultipleEventsEntry>) -> Void) {
        var selectedEvents: [WidgetContent] = []

        // Fetch events based on intent configuration (now including event4 and event5)
        let eventIDs = [
            configuration.event1?.identifier,
            configuration.event2?.identifier,
            configuration.event3?.identifier,
            configuration.event4?.identifier,
            configuration.event5?.identifier
        ].compactMap { $0 } // Get non-nil IDs

        for eventId in eventIDs {
            if let matchingItem = items.first(where: { $0.id.uuidString == eventId }) {
                selectedEvents.append(WidgetContent(item: matchingItem))
            }
        }

        
        // The view will display however many were actually selected (up to 5).
        // Create the timeline entry with the fetched events
        var entry = MultipleEventsEntry(date: Date(), events: [WidgetContent(date: Date(), name: "No events", id: UUID(), color: .green, daysNumber: 4)])
        
        if !selectedEvents.isEmpty {
            entry = MultipleEventsEntry(date: Date(), events: selectedEvents)
        }
        
        let timeline = Timeline(entries: [entry], policy: .atEnd)
        completion(timeline)
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
