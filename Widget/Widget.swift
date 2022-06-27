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

    @AppStorage("items", store: UserDefaults(suiteName: "group.goodsnooze.dayssince")) var items: [DaysSinceItem] = []
    
//    var travelCardsManager = TravelCardsManager.shared

    func placeholder(in context: Context) -> WidgetContent {

        let content = WidgetContent(date: Date(), name: "TEST EVENT", id: UUID())

        return content
    }

    public func getSnapshot(
        for configuration: SelectEventIntent,
        in context: Context,
        completion: @escaping (WidgetContent) -> Void
    ) {
        let content = WidgetContent(date: Date(), name: "TEST EVENT", id: UUID())
        completion(content)
    }

    public func getTimeline(
        for configuration: SelectEventIntent,
        in context: Context,
        completion: @escaping (Timeline<WidgetContent>) -> Void
    ) {
        
        
        let id = configuration.event?.displayString ?? "No id"
        let displayString = configuration.event?.displayString ?? "No displaystring"
        
        // array of all the names of the items
//        let itemNames = items.map { "\($0.name + $0.id.uuidString)" }.joined(separator: "+")

        guard let matchingEvent = items.first(where: { $0.name == displayString }) else {
            let content = WidgetContent(date: Date(), name: "NO events found", id: UUID())
            completion(Timeline(entries: [content], policy: .atEnd))
            return
        }
        
        let content = WidgetContent(date: matchingEvent.dateLastDone, name: matchingEvent.name, id: matchingEvent.id)

        completion(Timeline(entries: [content], policy: .atEnd))
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

    @ViewBuilder
    var body: some View {
        ZStack(alignment: .leading) {
            Color.white
            itemContent
        }
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.red,lineWidth: 6)
        )
        
        .shadow(color: Color.black.opacity(0.05), radius: 20, x: 0, y: 0)
    }

    var nameText: some View {
        Text(event.name)
            .font(.system(.title2, design: .rounded))
            .bold()
            .foregroundColor(.red)
    }
    
    var daysAgoText: some View {
        VStack {
            Text("\(event.date)")
                .font(.system(.title2, design: .rounded))
                .bold()
                .foregroundColor(.red)
            
            Text("days")
                .font(.system(.body, design: .rounded))
                .foregroundColor(.red)
        }
        .frame(width: 40)
    }
    


    var itemContent: some View {
        VStack {
            daysAgoText
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
    
    init(date: Date, name: String, id: UUID) {
        self.date = date
        self.name = name
        self.id = id
    }
}
