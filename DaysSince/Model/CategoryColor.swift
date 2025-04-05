//
//  CategoryColor.swift
//  DaysSince
//
//  Created by Vicki Minerva on 11/22/23.
//

import Foundation
import SwiftUI

/// Represents the color of a category. Used to store in user defaults.
enum CategoryColor: Codable, Identifiable, Equatable, CaseIterable, Hashable {
    static var allCases: [CategoryColor] = [
        .work, .life, .hobbies, .health, .marioBlue, .zeldaYellow, .animalCrossingsGreen, .marioRed, .animalCrossingsBrown, .black
    ]

    case work
    case life
    case health
    case hobbies
    case marioBlue
    case zeldaYellow
    case animalCrossingsGreen
    case marioRed
    case animalCrossingsBrown
    case black

    var id: String {
        switch self {
        case .work:
            return "Work"
        case .life:
            return "Life"
        case .health:
            return "Health"
        case .hobbies:
            return "Hobby"
        case .marioBlue:
            return "MarioBlue"
        case .zeldaYellow:
            return "ZeldaYellow"
        case .animalCrossingsGreen:
            return "AnimalCrossingsGreen"
        case .marioRed:
            return "MarioRed"
        case .animalCrossingsBrown:
            return "AnimalCrossingsBrown"
        case .black:
            return "Black"
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
        case .marioBlue:
            return Color.marioBlue
        case .zeldaYellow:
            return Color.zeldaYellow
        case .animalCrossingsGreen:
            return Color.animalCrossingsGreen
        case .marioRed:
            return Color.marioRed
        case .animalCrossingsBrown:
            return Color.animalCrossingsBrown
        case .black:
            return Color.black
        }
    }
    
    func foregroundColor(for colorScheme: ColorScheme) -> Color {
        if self == .black && colorScheme == .dark {
            return Color.white
        } else {
            return self.color
        }
    }
}
