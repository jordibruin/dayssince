//
//  HighlightedItem.swift
//  Supporter
//
//  Created by Jordi Bruin on 05/12/2021.
//

import Foundation

struct HighlightedItem: Identifiable, Codable, SupportPageable {
    let id: Int
    let title: String
    let subtitle: String
    let imageName: String
    let emoji: String?
    let color: SupportColor?
    let supportPages: [SupportItemPage]

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(Int.self, forKey: .id) ?? 0
        title = try container.decodeIfPresent(String.self, forKey: .title) ?? ""
        subtitle = try container.decodeIfPresent(String.self, forKey: .subtitle) ?? ""
        imageName = try container.decodeIfPresent(String.self, forKey: .imageName) ?? ""
        emoji = try container.decodeIfPresent(String.self, forKey: .emoji)
        color = try container.decodeIfPresent(SupportColor.self, forKey: .color) ?? .primary
        supportPages = try container.decodeIfPresent([SupportItemPage].self, forKey: .supportPages) ?? []
    }

    init(
        id: Int,
        title: String,
        subtitle: String,
        imageName: String,
        emoji: String? = nil,
        color: SupportColor? = nil,
        supportPages: [SupportItemPage]
    ) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.imageName = imageName
        self.emoji = emoji
        self.color = color ?? .primary
        self.supportPages = supportPages
    }

    static let example = HighlightedItem(id: Int.random(in: 1 ... 4_032_304), title: "How to enable subsitles", subtitle: "Four simple steps", imageName: "captions.bubble.fill", emoji: "😃", color: .primary, supportPages: [])
}
