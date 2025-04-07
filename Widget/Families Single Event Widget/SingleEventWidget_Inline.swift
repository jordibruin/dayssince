//
//  SingleEventWidget_Inline.swift
//  WidgetExtension
//
//  Created by Victoria Petrova on 07/04/2025.
//

import SwiftUI
import Foundation
import WidgetKit

struct SingleEventWidget_Inline: View {
    var event: WidgetContent
    
    var body: some View {
        Group {
            if event.name == "No event" {
                Text("Tap to select event!")
            } else {
                Text("\(event.daysNumber) \(event.daysNumber > 0 ? "days" : "day") since \(event.name) ")
                    .privacySensitive()
            }
        }
        .widgetBackground(Color.clear)
    }
}
