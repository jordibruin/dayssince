//
//  HeaderItem.swift
//  Supporter
//
//  Created by Jordi Bruin on 05/12/2021.
//

import Foundation

struct HeaderItem: Identifiable, Codable, SupportPageable, SupportItemable {
    let id: Int
    let title: String
    let imageName: String
    let color: SupportColor
    let supportPages: [SupportItemPage]

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(Int.self, forKey: .id) ?? 0
        title = try container.decodeIfPresent(String.self, forKey: .title) ?? ""
        imageName = try container.decodeIfPresent(String.self, forKey: .imageName) ?? ""
        color = try container.decodeIfPresent(SupportColor.self, forKey: .color) ?? .primary
        supportPages = try container.decodeIfPresent([SupportItemPage].self, forKey: .supportPages) ?? []
    }

    init(
        id: Int,
        title: String,
        imageName: String? = "",
        color: SupportColor = .primary,
        supportPages: [SupportItemPage]
    ) {
        self.id = id
        self.title = title
        self.imageName = imageName ?? ""
        self.color = color
        self.supportPages = supportPages
    }

    static let example = HeaderItem(id: Int.random(in: 1 ... 4_032_304), title: "How to enable subsitles", imageName: "captions.bubble.fill", color: .primary, supportPages: [])
}
