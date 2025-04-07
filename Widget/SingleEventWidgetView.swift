//
//  SingleEventWidgetView.swift
//  WidgetExtension
//
//  Created by Victoria Petrova on 07/04/2025.
//

import SwiftUI
import WidgetKit

struct EventCardWidgetView: View {
    let event: WidgetContent

    @Environment(\.widgetFamily) var family
    @Environment(\.colorScheme) var colorScheme

    @AppStorage("isDaysDisplayModeDetailed", store: UserDefaults(suiteName: "group.goodsnooze.dayssince")) var isDaysDisplayModeDetailed: Bool = true

    @ViewBuilder
    var body: some View {
        switch family {
        case .accessoryCircular:
            VStack {
                if event.name == "No event" {
                    Text("Tap to select!")
                } else {
                    Text("\(event.daysNumber)")
                        .font(.system(.title, design: .rounded))
                        .bold()
                        .widgetAccentable()
                    Text(event.daysNumber > 0 ? "days" : "day")
                        .fontDesign(.rounded)
                }
            }
            .widgetBackground(Color.clear)
        case .accessoryInline:
            Group {
                if event.name == "No event" {
                    Text("Tap to select event!")
                } else {
                    Text("\(event.daysNumber) \(event.daysNumber > 0 ? "days" : "day") since \(event.name) ")
                }
            }
            .widgetBackground(Color.clear)
        case .accessoryRectangular:
            HStack {
                if event.name == "No event" {
                    Text("Tap to select event!")
                } else {
                    Text(event.name)
                        .font(.system(.headline, design: .rounded))
                    Spacer()
                    VStack {
                        Text("\(event.daysNumber)")
                            .fontDesign(.rounded)
                            .bold()
                            .widgetAccentable()
                        Text(event.daysNumber > 0 ? "days" : "day")
                            .fontDesign(.rounded)
                    }
                }
            }
            
            .widgetBackground(Color.clear)
        default:
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
    }

    var nameText: some View {
        Text(event.name)
            .font(.system(.title2, design: .rounded))
            .bold()
            .foregroundColor(colorScheme == .dark ? .primary : event.color)
            .minimumScaleFactor(0.6) // Text fits in widget
    }

    @ViewBuilder
    var daysAgoText: some View {
        let currentDate = Date()
        let calendar = Calendar.current

        let dateComponents = calendar.dateComponents([.year, .month, .day], from: calendar.startOfDay(for: event.date), to: calendar.startOfDay(for: currentDate))

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
            VStack(alignment: .center) {
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
            if event.name != "No event" {
                daysAgoText
            }

            Spacer()
            nameText
        }
        .padding()
    }
}

struct EventCardWidgetView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            EventCardWidgetView(event: WidgetContent(date: Date.now, name: "Test event", id: UUID(), color: .workColor, daysNumber: 7))
                .previewContext(WidgetPreviewContext(family: .systemSmall))
                .previewDisplayName("Small Widget")
            
            EventCardWidgetView(event: WidgetContent(date: Date.now, name: "Test event", id: UUID(), color: .workColor, daysNumber: 7))
                .previewContext(WidgetPreviewContext(family: .systemMedium))
                .previewDisplayName("Medium Widget")
                .environment(\.colorScheme, .dark)
        }
    }
}
