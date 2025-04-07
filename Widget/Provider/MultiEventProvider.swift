//
//  MultiEventProvider.swift
//  WidgetExtension
//
//  Created by Victoria Petrova on 07/04/2025.
//

import Foundation
import WidgetKit
import SwiftUI

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
