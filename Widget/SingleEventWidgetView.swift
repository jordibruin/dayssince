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

    @ViewBuilder
    var body: some View {
        switch family {
        case .accessoryCircular:
            SingleEventWidget_Circular(event: event)
        case .accessoryInline:
            SingleEventWidget_Inline(event: event)
        case .accessoryRectangular:
            SingleEventWidget_Rectangular(event: event)
        case .systemSmall, .systemMedium:
            SingleEventWidget_Standard(event: event)
        default:
            Text("Some other WidgetFamily in the future.")
        }
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
