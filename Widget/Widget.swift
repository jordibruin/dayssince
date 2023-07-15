//
//  Widget.swift
//  Widget
//
//  Created by Jordi Bruin on 27/06/2022.
//

import WidgetKit
import SwiftUI

//let snapshotEntry = WidgetContent()

struct Provider: IntentTimelineProvider {

    @AppStorage("items", store: UserDefaults(suiteName: "group.goodsnooze.dayssince")) var items: [DSItem] = []
    
//    var travelCardsManager = TravelCardsManager.shared

    func placeholder(in context: Context) -> WidgetContent {

        let content = WidgetContent(date: Date(), name: "Adopted Leo 🐱", id: UUID(), color: Color.lifeColor, daysNumber: 237)

        return content
    }

    public func getSnapshot(
        for configuration: SelectEventIntent,
        in context: Context,
        completion: @escaping (WidgetContent) -> Void
    ) {
        let content = WidgetContent(date: Date(), name: "Adopted Charlie 🐶", id: UUID(), color: .green, daysNumber: 45)
        completion(content)
    }

    public func getTimeline(
        for configuration: SelectEventIntent,
        in context: Context,
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
    }
}


struct EventCardWidgetView: View {

    let event: WidgetContent

    @Environment(\.widgetFamily) var family
    @Environment(\.colorScheme) var colorScheme

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
                .stroke(colorScheme == .dark ? event.color.darker(): event.color, lineWidth: 6)
        )
        
        .shadow(color: Color.black.opacity(0.05), radius: 20, x: 0, y: 0)
    }

    var nameText: some View {
        Text(event.name)
            .font(.system(.title2, design: .rounded))
            .bold()
            .foregroundColor(colorScheme == .dark ? .primary : event.color)
    }
    
    var daysAgoText: some View {
        VStack(alignment: .leading) {
            Text("\(event.daysNumber)")
                .font(.system(.title2, design: .rounded))
                .bold()
                .foregroundColor(colorScheme == .dark ? .primary : event.color)
            
            Text("days")
                .font(.system(.body, design: .rounded))
                .foregroundColor(colorScheme == .dark ? .primary : event.color)
        }
        .frame(width: event.daysNumber > 999 ? 70 : event.daysNumber > 99 ? 50 : 40)
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
        self.date = item.dateLastDone
        self.name = item.name
        self.id = item.id
        self.color = item.category.color
        
        let daysSince = Calendar.current.numberOfDaysBetween(item.dateLastDone, and: Date.now)
        self.daysNumber = daysSince
    }
}
