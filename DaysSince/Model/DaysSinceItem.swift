//
//  idk.swift
//  DaysSince
//
//  Created by Vicki Minerva on 3/30/22.
//

import Foundation
import SwiftUI

struct DaysSinceItem: Identifiable, Codable {

    let id: UUID = UUID()

    /// The name of the item.
    var name: String

    /// The emoji of the item.
    var emoji: String

    /// Day last done.
    var dateLastDone: Date

    /// String for number of days since you did it.
    var daysAgo: Int {
        let daysSince = Calendar.current.numberOfDaysBetween(dateLastDone, and: Date.now)
        return abs(daysSince)
    }

    /// Color displayed on main screen.
    var color = colorDaysSinceItem.work
}

enum colorDaysSinceItem: Codable, Identifiable, Equatable, CaseIterable, Hashable {
    
    static var allCases: [colorDaysSinceItem] = [
        .work, .life, .hobbies, .health
    ]
    
    case work
    case life
    case health
    case hobbies
    
    var name: String {
        switch self {
        case .work:
            return "Work"
        case .life:
            return "Life"
        case .health:
            return "Health"
        case .hobbies:
            return "Hobbies"
        }
    }
    
    var id: String {
        switch self {
        case .work:
            return "Work"
        case .life:
            return "Life"
        case .health:
            return "Health"
        case .hobbies:
            return "Hobbies"
        }
    }
    
    var color: Color {
        switch self {
        case .work:
            return Color.workColor
        case .life:
            return Color.lifeColor
        case .health:
            return Color.healthColor
        case .hobbies:
            return Color.hobbiesColor
        }
        
    }
}
