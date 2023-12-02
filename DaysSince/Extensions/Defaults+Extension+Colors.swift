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
    static let categories = Key<[Category]>("categories", default: [
        Category(name: "Work", emoji: "lightbulb", color: .work),
        Category(name: "Life", emoji: "leaf", color: .life),
        Category(name: "Hobby", emoji: "gamecontroller", color: .hobbies),
        Category(name: "Health", emoji: "heart.text.square", color: .health)])
}
