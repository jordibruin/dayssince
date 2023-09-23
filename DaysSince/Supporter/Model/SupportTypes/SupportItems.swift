//
//  SupportItems.swift
//  Supporter
//
//  Created by Jordi Bruin on 01/12/2021.
//

import Foundation

class SupportItems: Codable {
    var releaseNotes: SupportReleaseNote?
    var headerItems: [HeaderItem]?
    var highlightedSections: [HighlightedSection]?
    var faqSections: [FAQSection]?
    var contactSections: [SupportSection]?
    var contactItems: [SupportContactItem]?
    var changelogItems: [ChangelogItem]?

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        releaseNotes = try container.decodeIfPresent(SupportReleaseNote.self, forKey: .releaseNotes)
        headerItems = try container.decodeIfPresent([HeaderItem].self, forKey: .headerItems)
        highlightedSections = try container.decodeIfPresent([HighlightedSection].self, forKey: .highlightedSections)
        faqSections = try container.decodeIfPresent([FAQSection].self, forKey: .faqSections)

        contactSections = try container.decodeIfPresent([SupportSection].self, forKey: .contactSections)
        contactItems = try container.decodeIfPresent([SupportContactItem].self, forKey: .contactItems)

        changelogItems = try container.decodeIfPresent([ChangelogItem].self, forKey: .changelogItems)
    }
}

protocol SupportPageable {
    var id: Int { get }
    var supportPages: [SupportItemPage] { get }
}
