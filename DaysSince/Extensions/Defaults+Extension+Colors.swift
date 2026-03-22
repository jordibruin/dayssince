//
//  Defaults+Extension+Colors.swift
//  DaysSince
//
//  Created by Vicki Minerva on 9/24/23.
//

import Defaults
import Foundation
import SwiftUI

extension Defaults.Keys {
    static let mainColor = Key<Color>("mainColor", default: Color.workColor)
    static let backgroundColor = Key<Color>("backgroundColor", default: Color.backgroundColor)
    static let selectedThemeId = Key<String>("selectedThemeId", default: "default")
    
    static let categories = Key<[Category]>("categories", default: [
        Category(stableID: Category.stableIDWork, name: "Work", emoji: "lightbulb", color: .work, sortOrder: 0),
        Category(stableID: Category.stableIDLife, name: "Life", emoji: "leaf", color: .life, sortOrder: 1),
        Category(stableID: Category.stableIDHobby, name: "Hobby", emoji: "gamecontroller", color: .hobbies, sortOrder: 2),
        Category(stableID: Category.stableIDHealth, name: "Health", emoji: "heart.text.square", color: .health, sortOrder: 3)])
}
