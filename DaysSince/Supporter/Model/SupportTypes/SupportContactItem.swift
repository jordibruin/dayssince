//
//  SupportContactItem.swift
//  Supporter
//
//  Created by Jordi Bruin on 05/12/2021.
//

import Foundation

struct SupportContactItem: Identifiable, Codable, Equatable {
    let id: Int
    let title: String
    let url: String
    let imageName: String
    let color: SupportColor

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(Int.self, forKey: .id) ?? 0
        title = try container.decodeIfPresent(String.self, forKey: .title) ?? ""
        url = try container.decodeIfPresent(String.self, forKey: .url) ?? ""
        imageName = try container.decodeIfPresent(String.self, forKey: .imageName) ?? ""
        color = try container.decodeIfPresent(SupportColor.self, forKey: .color) ?? .primary
    }

    init(
        id: Int,
        title: String,
        url: String,
        imageName: String?,
        color: SupportColor = .primary
    ) {
        self.id = id
        self.title = title
        self.url = url
        self.imageName = imageName ?? ""
        self.color = color
    }

    static let example = SupportContactItem(id: Int.random(in: 1 ... 4_032_304), title: "Naam", url: "https://www.google.com", imageName: "message.fill", color: .primary)
}
