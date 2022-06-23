//
//  DStemReminders.swift
//  DaysSince
//
//  Created by Vicki Minerva on 6/3/22.
//

import Foundation


enum DSItemReminders: Codable, Equatable, CaseIterable, Hashable {
    
    
    static var allCases: [DSItemReminders] = [
        .daily, .weekly, .monthly, .none
    ]
    
    case daily
    case weekly
    case monthly
    case none
    
    var name: String {
        switch self {
        case .daily:
            return "Daily"
        case .weekly:
            return "Weekly"
        case .monthly:
            return "Monthly"
        case .none:
            return "No reminders"
        }
    }
    
//    var dateComponents: DateComponents {
//        switch self {
//        case .daily:
//            dateComponents.hour = 10
//            return dateComponents
//        case .weekly:
//            return dateComponents.day = "Monday"
//        case .monthly:
//            return dateC
//        }
//    }
}
