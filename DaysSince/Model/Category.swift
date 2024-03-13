//
//  Category.swift
//  DaysSince
//
//  Created by Vicki Minerva on 11/22/23.
//

import Defaults
import Foundation
import SwiftUI

struct Category: Identifiable, Codable, Equatable, Defaults.Serializable {
    let id: UUID
    var name: String
    var emoji: String
    var color: CategoryColor

    init(id: UUID = UUID(), name: String, emoji: String, color: CategoryColor) {
        self.id = id
        self.name = name
        self.emoji = emoji
        self.color = color
    }

    static func == (lhs: Category, rhs: Category) -> Bool {
        return lhs.id == rhs.id
    }

    // Computed property for a hashable identifier
    var hashableIdentifier: String {
        return "\(id)-\(name)-\(emoji)-\(color)"
    }

    static func placeholderCategory() -> Category {
        return Category(name: "Placeholder", emoji: "placeholder", color: .work)
    }
}
