//
//  SingleEventWidget_Rectangular.swift
//  WidgetExtension
//
//  Created by Victoria Petrova on 07/04/2025.
//

import SwiftUI
import Foundation
import WidgetKit

struct SingleEventWidget_Rectangular: View {
    var event: WidgetContent
    
    var body: some View {
        HStack {
            if event.name == "No event" {
                Text("Tap to select event!")
            } else {
                Text(event.name)
                    .font(.system(.headline, design: .rounded))
                    .privacySensitive()
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
    }
}
