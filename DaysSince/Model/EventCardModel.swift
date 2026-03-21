//
//  EventCardModel.swift
//  DaysSince
//
//  Created by Victoria Petrova on 04/05/2025.
//

import SwiftUI

struct EventCardModel: Identifiable {
    let id: UUID
    let name: String
    let dateLastDone: Date
    let color: Color

    var daysNumber: Int {
        Calendar.current.numberOfDaysBetween(dateLastDone, and: Date())
    }

    var dateComponents: DateComponents {
        Calendar.current.dateComponents([.year, .month, .day], from: dateLastDone, to: Date())
    }

    static func dummyEvents() -> [EventCardModel] { [
            .init(dateLastDone: Calendar.daysAgo(37), name: "✂️ Haircut", color: .animalCrossingsGreen),
            .init(dateLastDone: Calendar.daysAgo(17), name: "🐾 Cat litter", color: .hobbiesColor),
            .init(dateLastDone: Calendar.daysAgo(1), name: "🏃‍♂️ Work out", color: .marioBlue),
            .init(dateLastDone: Calendar.daysAgo(5), name: "🧹 Vacuum", color: .workColor),
            .init(dateLastDone: Calendar.daysAgo(25*365+2*30+13), name: "🐣 I was born", color: .marioRed),
            .init(dateLastDone: Calendar.daysAgo(3), name: "👯 Hung out with friends",  color: .lifeColor)
        ]
    }
    
    static func mock() -> EventCardModel { .init(dateLastDone: Calendar.daysAgo(3), name: "👯 Hung out with friends",  color: .lifeColor)}

    init(id: UUID = UUID(), dateLastDone: Date, name: String, color: Color) {
        self.id = id
        self.name = name
        self.dateLastDone = dateLastDone
        self.color = color
    }

    init(from item: DSItem) {
        self.id = item.id
        self.name = item.name
        self.dateLastDone = item.dateLastDone
        self.color = item.category.color.color
    }
}
