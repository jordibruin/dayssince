//
//  HighlightedSection.swift
//  Supporter
//
//  Created by Jordi Bruin on 30/12/2021.
//

import Foundation

struct HighlightedSection: Identifiable, Codable, SupportItemable {
    let id: Int
    let title: String
    let items: [HighlightedItem]
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decodeIfPresent(Int.self, forKey: .id) ?? 0
        self.title = try container.decodeIfPresent(String.self, forKey: .title) ?? ""
        self.items = try container.decodeIfPresent([HighlightedItem].self, forKey: .items) ?? []
    }
    
    init(
        id: Int,
        title: String,
        items: [HighlightedItem]
    ) {
        self.id = id
        self.title = title
        self.items = items
    }

    static let example = HighlightedSection(id: 0, title: "Section title", items: [
        HighlightedItem(id: Int.random(in: 1...4032304), title: "How to enable subsitles", subtitle: "Four simple steps", imageName: "captions.bubble.fill", emoji: "🤫", color: .primary, supportPages: []),
        HighlightedItem(id: Int.random(in: 1...4032304), title: "How to enable subsitles", subtitle: "Four simple steps", imageName: "captions.bubble.fill", emoji: "🤫", color: .primary, supportPages: [])
    ])
}
