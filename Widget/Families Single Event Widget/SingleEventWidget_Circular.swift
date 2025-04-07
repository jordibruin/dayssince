//
//  SingleEventWidget_Circular.swift
//  WidgetExtension
//
//  Created by Victoria Petrova on 07/04/2025.
//

import SwiftUI
import Foundation
import WidgetKit

struct SingleEventWidget_Circular: View {
    var event: WidgetContent
    
    var body: some View {
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
    }
}
