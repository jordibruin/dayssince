//
//  Widget.swift
//  Widget
//
//  Created by Jordi Bruin on 27/06/2022.
//

import Defaults
import SwiftUI
import WidgetKit

// let snapshotEntry = WidgetContent()

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

@main
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
        .configurationDisplayName(LocalizedStringKey("widget.title.singleEvent"))
        .description(LocalizedStringKey("widget.explanation.singleEvent"))
        .contentMarginsDisabled() // iOS17 widgets force additional margin padding on your design
    }
}


struct WidgetContent: TimelineEntry {
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
