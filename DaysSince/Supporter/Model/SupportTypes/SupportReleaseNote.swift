//
//  SupportReleaseNote.swift
//  Supporter
//
//  Created by Jordi Bruin on 05/12/2021.
//

import Foundation

struct SupportReleaseNote: Identifiable, Codable {
    let id: Int
    let title: String
    let version: String
    let description: String
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decodeIfPresent(Int.self, forKey: .id) ?? 0
        self.title = try container.decodeIfPresent(String.self, forKey: .title) ?? ""
        self.version = try container.decodeIfPresent(String.self, forKey: .version) ?? ""
        self.description = try container.decodeIfPresent(String.self, forKey: .description) ?? ""
    }
    
    init(
        id: Int,
        title: String,
        version: String = "",
        description: String = ""
    ) {
        self.id = id
        self.title = title
        self.version = version
        self.description = description
    }
}
