//
//  Category.swift
//  DaysSince
//
//  Created by Vicki Minerva on 11/22/23.
//

import Defaults
import Foundation
import SwiftUI

/// Category object that a Days Since event/item is categorized into.
///
/// `stableID` is the persistent identity used to link events to categories.
/// Unlike `id` (a UUID that can be regenerated if stored data is lost),
/// `stableID` is hardcoded for built-in categories and generated once for
/// user-created categories, then persisted forever.
struct Category: Identifiable, Codable, Equatable, Defaults.Serializable, Hashable {
    let id: UUID

    /// Stable, persistent identifier. Used as the foreign key in DSItem.
    /// Built-in categories use well-known values ("work", "life", "hobby", "health").
    /// User-created categories get a UUID string generated once at creation time.
    let stableID: String

    var name: String
    var emoji: String
    var color: CategoryColor

    init(id: UUID = UUID(), stableID: String = UUID().uuidString, name: String, emoji: String, color: CategoryColor) {
        self.id = id
        self.stableID = stableID
        self.name = name
        self.emoji = emoji
        self.color = color
    }

    static func == (lhs: Category, rhs: Category) -> Bool {
        return lhs.stableID == rhs.stableID
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(stableID)
    }

    var hashableIdentifier: String {
        return "\(stableID)-\(name)-\(emoji)-\(color)"
    }

    static func placeholderCategory() -> Category {
        return Category(stableID: "placeholder", name: "Placeholder", emoji: "placeholder", color: .work)
    }

    // MARK: - Built-in Stable IDs

    static let stableIDWork = "work"
    static let stableIDLife = "life"
    static let stableIDHobby = "hobby"
    static let stableIDHealth = "health"
    static let stableIDHome = "home"
    static let stableIDPet = "pet"
    static let stableIDFriends = "friends"
    static let stableIDProjects = "projects"
    static let stableIDJournal = "journal"
}

// Custom decoder in an extension to preserve the memberwise init.
// Handles migration from stored data that predates the stableID field:
// generates a deterministic stableID from the category name (lowercased)
// so that built-in categories ("Work" → "work") get their well-known IDs.
extension Category {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        emoji = try container.decode(String.self, forKey: .emoji)
        color = try container.decode(CategoryColor.self, forKey: .color)

        if let decoded = try container.decodeIfPresent(String.self, forKey: .stableID) {
            stableID = decoded
        } else {
            // Migration: derive stableID from name for built-in categories,
            // or generate a UUID string for unknown ones.
            let knownBuiltIns: [String: String] = [
                "Work": Category.stableIDWork,
                "Life": Category.stableIDLife,
                "Hobby": Category.stableIDHobby,
                "Health": Category.stableIDHealth,
                "Home": Category.stableIDHome,
                "Pet": Category.stableIDPet,
                "Friends": Category.stableIDFriends,
                "Projects": Category.stableIDProjects,
                "Journal": Category.stableIDJournal,
            ]
            stableID = knownBuiltIns[name] ?? UUID().uuidString
        }
    }
}
