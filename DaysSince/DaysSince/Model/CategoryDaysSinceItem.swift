//
//  CategoryDaysSinceItem.swift
//  DaysSince
//
//  Created by Vicki Minerva on 5/25/22.
//

import Foundation
import SwiftUI

enum categoryDaysSinceItem: Codable, Identifiable, Equatable, CaseIterable, Hashable {
    
    static var allCases: [categoryDaysSinceItem] = [
        .work, .life, .hobbies, .health, .none
    ]
    
    case work
    case life
    case health
    case hobbies
    case none
    
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
        case .none:
            return "No cattegory"
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
        case .none:
            return "No Category"
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
        case .none:
            return Color.black
        }
    }
    
    var emoji: String {
        switch self {
        case .work:
            return "workCategoryIcon"
        case .life:
            return "lifeCategoryIcon"
        case .health:
            return "healthCategoryIcon"
        case .hobbies:
            return "hobbiesCategoryIcon"
        case .none:
            return ""
        }
    }
    
}
