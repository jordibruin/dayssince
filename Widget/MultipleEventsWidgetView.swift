//
//  MultipleEventsWidgetView.swift
//  WidgetExtension
//
//  Created by Victoria Petrova on 07/04/2025.
//

import SwiftUI

struct MultipleEventsWidgetView: View {
    let entry: MultipleEventsEntry
    @Environment(\.widgetFamily) var family
    @Environment(\.colorScheme) var colorScheme

    // Determine background color based on scheme
    private var backgroundColor: Color {
        colorScheme == .dark ? Color(.systemGray6) : .white
    }

    // Determine border color (using green as per example)
    private var borderColor: Color {
        .green // Consistent green border
    }

    // Determine text color based on scheme
//    private var primaryTextColor: Color {
//        colorScheme == .dark ? .white : .black
//    }
//
//    private var secondaryTextColor: Color {
//        colorScheme == .dark ? .gray : .darkGray
//    }

    var body: some View {
        // Use systemMedium as the target layout based on the screenshot
        VStack(alignment: .leading, spacing: 4) { // Reduced spacing for tighter list
            // Iterate over all available events (up to 5), removing the prefix limit
            ForEach(entry.events) { event in
                 HStack {
                    Text(event.name)
                        .font(.system(.footnote, design: .rounded))
                        .fontWeight(.medium)
//                        .foregroundColor(primaryTextColor)
                        .lineLimit(1)
                    Spacer()
                    Text("\\(event.daysNumber) days")
                        .font(.system(.caption, design: .rounded))
                        .fontWeight(.bold)
//                         .foregroundColor(secondaryTextColor) // Use secondary color for days
                         .padding(.horizontal, 6)
                         .padding(.vertical, 2)
//                         .background(secondaryTextColor.opacity(0.1)) // Subtle background
                         .clipShape(Capsule())
                }
                 // Add divider logic if desired, checking against last ID
                 if event.id != entry.events.last?.id {
                    // Divider().background(borderColor.opacity(0.5)) // Optional subtle divider
                 }
            }
             Spacer() // Push content to top
        }
        .padding()
        .background(backgroundColor) // Use dynamic background
        .clipShape(RoundedRectangle(cornerRadius: 16)) // Standard corner radius
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                 .stroke(borderColor, lineWidth: 4) // Consistent green border
        )
        .widgetBackground(Color.clear) // iOS 17 background handling
    }
}

//#Preview {
//    MultipleEventsWidgetView()
//}
