//
//  WidgetContent.swift
//  WidgetExtension
//
//  Created by Victoria Petrova on 07/04/2025.
//

import Foundation
import SwiftUI
import WidgetKit

// Define the data structure for the single and multiple event widgets
struct WidgetContent: TimelineEntry, Identifiable {
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
