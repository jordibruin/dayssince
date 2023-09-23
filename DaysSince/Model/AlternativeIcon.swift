//
//  AlternativeIcon.swift
//  DaysSince
//
//  Created by Vicki Minerva on 6/29/22.
//

import Foundation

struct AlternativeIcon: Identifiable {
    var id: String {
        return name + iconName
    }

    let name: String
    let iconName: String
    let premium: Bool

    let original: Bool
}
