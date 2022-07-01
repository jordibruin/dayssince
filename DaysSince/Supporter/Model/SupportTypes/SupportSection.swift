//
//  SupportSection.swift
//  Supporter
//
//  Created by Jordi Bruin on 31/12/2021.
//

import Foundation

struct SupportSection: Identifiable, Codable, SupportItemable {
    let id: Int
    let title: String
    let items: [SupportContactItem]
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decodeIfPresent(Int.self, forKey: .id) ?? 0
        self.title = try container.decodeIfPresent(String.self, forKey: .title) ?? ""
        self.items = try container.decodeIfPresent([SupportContactItem].self, forKey: .items) ?? []
    }
    
    init(
        id: Int,
        title: String,
        items: [SupportContactItem]
    ) {
        self.id = id
        self.title = title
        self.items = items
    }

    static let example = SupportSection(id: 0, title: "Contact us", items: [
        SupportContactItem(id: Int.random(in: 1...4032304), title: "Naam", url: "https://www.google.com", imageName: "message.fill", color: .primary),
        SupportContactItem(id: Int.random(in: 1...4032304), title: "Naam", url: "https://www.google.com", imageName: "message.fill", color: .primary)
    ])
}
