//
//  ChangelogItem.swift
//  SnoozeSupport
//
//  Created by Jordi Bruin on 02/01/2022.
//

import Foundation

struct ChangelogItem: Identifiable, Codable, Comparable {
    
    static func < (lhs: ChangelogItem, rhs: ChangelogItem) -> Bool {
        return lhs.id < rhs.id
    }
    
    static func == (lhs: ChangelogItem, rhs: ChangelogItem) -> Bool {
        return lhs.id == rhs.id
    }
    
    let id: Int
    let version: String
    let date: String?
    let notes: [ReleaseNote]

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decodeIfPresent(Int.self, forKey: .id) ?? 0
        self.version = try container.decodeIfPresent(String.self, forKey: .version) ?? ""
        self.date = try container.decodeIfPresent(String.self, forKey: .date)
        self.notes = try container.decodeIfPresent([ReleaseNote].self, forKey: .notes) ?? []
    }
    
    init(
        id: Int,
        version: String,
        date: String? = nil,
        notes: [ReleaseNote]
    ) {
        self.id = id
        self.version = version
        self.date = date
        self.notes = notes
    }
    
    static let example = ChangelogItem(
        id: 1,
        version: "1.2",
        date: "2 January 2022",
        notes: [
            ReleaseNote(id: 1, releaseNote: "This is the note")
        ]
    )
}

struct ReleaseNote: Identifiable, Codable {
    let id: Int
    let releaseNote: String
    
    init(
        id: Int,
        releaseNote: String
    ) {
        self.id = id
        self.releaseNote = releaseNote
    }
    
}
