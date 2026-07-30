//
//  SeedData.swift
//  DaysSinceUITests
//

import Foundation

/// Mirror of what `-seedDemoData` writes (`DaysSinceApp.seedDemoData`). Sorting assertions need the
/// day count and category of each event, and neither is readable from the list: the day label
/// switches between simple and detailed rendering, and the category is only expressed as a colour.
/// **Change this table and `seedDemoData` together.**
enum SeedData {

    struct Event {
        let name: String
        let category: String
        let daysAgo: Int
    }

    static let events: [Event] = [
        .init(name: "📊 Performance review", category: "Work", daysAgo: 30),
        .init(name: "💼 Resume update", category: "Work", daysAgo: 90),
        .init(name: "✂️ Haircut", category: "Life", daysAgo: 37),
        .init(name: "👯 Hung out with friends", category: "Life", daysAgo: 3),
        .init(name: "🏃‍♂️ Work out", category: "Hobby", daysAgo: 1),
        .init(name: "🎮 Game night", category: "Hobby", daysAgo: 7),
        .init(name: "🏥 Dentist visit", category: "Health", daysAgo: 180),
        .init(name: "💊 Vitamins refill", category: "Health", daysAgo: 30),
        .init(name: "💧 Water filter change", category: "Home", daysAgo: 60),
        .init(name: "🐾 Cat litter", category: "Pet", daysAgo: 17),
        .init(name: "💉 Dog vaccination", category: "Pet", daysAgo: 365),
        .init(name: "🎁 Birthday gift", category: "Friends", daysAgo: 14),
        .init(name: "🔨 Side project update", category: "Projects", daysAgo: 7),
        .init(name: "📝 Blog post", category: "Projects", daysAgo: 30),
        .init(name: "📓 Journaled", category: "Journal", daysAgo: 1),
        .init(name: "🧘 Meditation", category: "Journal", daysAgo: 2)
    ]

    static let categoryNames = ["Work", "Life", "Hobby", "Health", "Home", "Pet", "Friends", "Projects", "Journal"]

    static func daysAgo(of name: String) -> Int? {
        events.first { $0.name == name }?.daysAgo
    }

    static func category(of name: String) -> String? {
        events.first { $0.name == name }?.category
    }
}
