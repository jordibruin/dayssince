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
struct SooseeWidget: Widget {
    let kind: String = "SooseeWidget"

    public var body: some WidgetConfiguration {
        IntentConfiguration(
            kind: kind,
            intent: SelectEventIntent.self,
            provider: Provider()
        ) { entry in
            EventCardWidgetView(event: entry)
//            TravelCardWidgetView(viewModel: TravelCardWidgetViewModel(content: entry))
        }
        .configurationDisplayName(LocalizedStringKey("widget.title"))
        .description(LocalizedStringKey("widget.explanation"))
        .contentMarginsDisabled() // iOS17 widgets force additional margin padding on your design
    }
}

struct EventCardWidgetView: View {
    let event: WidgetContent

    @Environment(\.widgetFamily) var family
    @Environment(\.colorScheme) var colorScheme

    @AppStorage("isDaysDisplayModeDetailed", store: UserDefaults(suiteName: "group.goodsnooze.dayssince")) var isDaysDisplayModeDetailed: Bool = true

    @ViewBuilder
    var body: some View {
        ZStack(alignment: .leading) {
            if colorScheme == .dark {
                event.color.lighter(by: 0.04)
            } else {
                Color.white
            }
            itemContent
        }
        .clipShape(RoundedRectangle(cornerRadius: 23))
        .overlay(
            RoundedRectangle(cornerRadius: 23)
                .stroke(colorScheme == .dark ? event.color.darker() : event.color, lineWidth: 6)
        )
        .shadow(color: Color.black.opacity(0.05), radius: 20, x: 0, y: 0)
        .widgetBackground(Color.clear) // Widgets changed with iOS 17, need to set the background to make them work 
    }

    var nameText: some View {
        Text(event.name)
            .font(.system(.title2, design: .rounded))
            .bold()
            .foregroundColor(colorScheme == .dark ? .primary : event.color)
    }

    @ViewBuilder
    var daysAgoText: some View {
        let currentDate = Date()
        let calendar = Calendar.current

        let dateComponents = calendar.dateComponents([.year, .month, .day], from: event.date, to: currentDate)

        let years = dateComponents.year ?? 0
        let months = dateComponents.month ?? 0
        let days = dateComponents.day ?? 0

        if isDaysDisplayModeDetailed {
            HStack(alignment: .top, spacing: 6) {
                if years > 0 {
                    VStack(alignment: .center) {
                        Text("\(years)")
                            .font(.system(.title2, design: .rounded))
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
                            .font(.system(.title2, design: .rounded))
                            .bold()
                            .foregroundColor(colorScheme == .dark ? .primary : event.color)

                        Text(months == 1 ? "month" : "months")
                            .font(.system(years > 0 ? .caption : .body, design: .rounded))
                            .foregroundColor(colorScheme == .dark ? .primary : event.color)
                    }
                }

                VStack(alignment: .center) {
                    Text("\(days)")
                        .font(.system(.title2, design: .rounded))
                        .bold()
                        .foregroundColor(colorScheme == .dark ? .primary : event.color)

                    Text(days == 1 ? "day" : "days")
                        .font(.system(years > 0 ? .caption : .body, design: .rounded))
                        .foregroundColor(colorScheme == .dark ? .primary : event.color)
                }
            }
            .padding(.trailing, 0)
        } else {
            VStack(alignment: .leading) {
                Text("\(event.daysNumber)")
                    .font(.system(event.daysNumber > 9999 ? .title3 : .title2, design: .rounded))
                    .bold()
                    .foregroundColor(colorScheme == .dark ? .primary : event.color)

                Text("days")
                    .font(.system(.body, design: .rounded))
                    .foregroundColor(colorScheme == .dark ? .primary : event.color)
            }
            .frame(width: event.daysNumber > 999 ? 70 : event.daysNumber > 99 ? 50 : 40)
        }
    }

    var itemContent: some View {
        VStack(alignment: .leading) {
            if event.name != "No events" {
                daysAgoText
            }

            Spacer()
            nameText
        }
        .padding()
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
        daysNumber = daysSince
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
