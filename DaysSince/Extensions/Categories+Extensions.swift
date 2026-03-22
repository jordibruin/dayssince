//
//  Categories+Extensions.swift
//  DaysSince
//
//  Created by Victoria Petrova on 04/05/2025.
//

import Foundation

extension Category {
    static let sampleList: [Category] = [
        .init(stableID: stableIDWork, name: "Work", emoji: "lightbulb", color: .work),
        .init(stableID: stableIDLife, name: "Life", emoji: "leaf", color: .life),
        .init(stableID: stableIDHobby, name: "Hobby", emoji: "gamecontroller", color: .hobbies),
        .init(stableID: stableIDHealth, name: "Health", emoji: "heart.text.square", color: .health),
        .init(stableID: stableIDHome, name: "Home", emoji: "house", color: .marioBlue),
        .init(stableID: stableIDPet, name: "Pet", emoji: "dog", color: .animalCrossingsBrown),
        .init(stableID: stableIDFriends, name: "Friends", emoji: "heart", color: .animalCrossingsGreen),
        .init(stableID: stableIDProjects, name: "Projects", emoji: "lightbulb", color: .zeldaYellow),
        .init(stableID: stableIDJournal, name: "Journal", emoji: "pencil", color: .marioRed)
    ]
}
