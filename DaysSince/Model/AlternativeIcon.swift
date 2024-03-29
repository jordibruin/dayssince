//
//  AlternativeIcon.swift
//  DaysSince
//
//  Created by Vicki Minerva on 6/29/22.
//

import Foundation

/// Represent alternative app icons for the app.
struct AlternativeIcon: Identifiable {
    var id: String {
        return name + iconName
    }

    let name: String
    let iconName: String
    let premium: Bool

    let original: Bool
}
