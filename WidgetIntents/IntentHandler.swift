//
//  IntentHandler.swift
//  WidgetIntents
//
//  Created by Jordi Bruin on 27/06/2022.
//

import Defaults
import Intents
import SwiftUI

class IntentHandler: INExtension, SelectEventIntentHandling {
    @AppStorage("items", store: UserDefaults(suiteName: "group.goodsnooze.dayssince")) var items: [DSItem] = []

    func provideEventOptionsCollection(for _: SelectEventIntent) async throws -> INObjectCollection<WidgetDaysSinceEvent> {
        let events = items.map { WidgetDaysSinceEvent(identifier: $0.id.uuidString, display: $0.name) }
        return INObjectCollection(items: events)
    }

    override func handler(for _: INIntent) -> Any {
        // This is the default implementation.  If you want different objects to handle different intents,
        // you can override this and return the handler you want for that particular intent.

        return self
    }
}
