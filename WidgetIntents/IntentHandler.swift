//
//  IntentHandler.swift
//  WidgetIntents
//
//  Created by Jordi Bruin on 27/06/2022.
//

import Defaults
import Intents
import SwiftUI

class IntentHandler: INExtension, SelectEventIntentHandling, SelectMultipleEventsIntentHandling {
    @AppStorage("items", store: UserDefaults(suiteName: "group.goodsnooze.dayssince")) var items: [DSItem] = []

    // MARK: - SelectEventIntentHandling (Single Event)
    func provideEventOptionsCollection(for _: SelectEventIntent) async throws -> INObjectCollection<WidgetDaysSinceEvent> {
        let events = items.map { WidgetDaysSinceEvent(identifier: $0.id.uuidString, display: $0.name) }
        return INObjectCollection(items: events)
    }

    // MARK: - SelectMultipleEventsIntentHandling (Multiple Events)

    // Provide options for the first event selection
    func provideEvent1OptionsCollection(for intent: SelectMultipleEventsIntent) async throws -> INObjectCollection<WidgetDaysSinceEvent> {
        let events = items.map { WidgetDaysSinceEvent(identifier: $0.id.uuidString, display: $0.name) }
        return INObjectCollection(items: events)
    }

    // Provide options for the second event selection
    func provideEvent2OptionsCollection(for intent: SelectMultipleEventsIntent) async throws -> INObjectCollection<WidgetDaysSinceEvent> {
        let events = items.map { WidgetDaysSinceEvent(identifier: $0.id.uuidString, display: $0.name) }
        return INObjectCollection(items: events)
    }

    // Provide options for the third event selection
    func provideEvent3OptionsCollection(for intent: SelectMultipleEventsIntent) async throws -> INObjectCollection<WidgetDaysSinceEvent> {
        let events = items.map { WidgetDaysSinceEvent(identifier: $0.id.uuidString, display: $0.name) }
        return INObjectCollection(items: events)
    }

    // Provide options for the fourth event selection
    func provideEvent4OptionsCollection(for intent: SelectMultipleEventsIntent) async throws -> INObjectCollection<WidgetDaysSinceEvent> {
        let events = items.map { WidgetDaysSinceEvent(identifier: $0.id.uuidString, display: $0.name) }
        return INObjectCollection(items: events)
    }

    // Provide options for the fifth event selection
    func provideEvent5OptionsCollection(for intent: SelectMultipleEventsIntent) async throws -> INObjectCollection<WidgetDaysSinceEvent> {
        let events = items.map { WidgetDaysSinceEvent(identifier: $0.id.uuidString, display: $0.name) }
        return INObjectCollection(items: events)
    }

    override func handler(for intent: INIntent) -> Any {
        // This is the default implementation. If you want different objects to handle different intents,
        // you can override this and return the handler you want for that particular intent.
        return self
    }
}
