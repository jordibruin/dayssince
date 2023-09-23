//
//  SupportColor.swift
//  Supporter
//
//  Created by Jordi Bruin on 05/12/2021.
//

import Foundation
import SwiftUI

// Used to pass colors from JSON to SwiftUI. You can customize the colors used here to match your project
enum SupportColor: Int, Codable {
    case primary = 0
    case secondary = 1
    case tertiary = 2

    var color: Color {
        switch self {
        case .primary:
            return .workColor
        case .secondary:
            return .lifeColor
        case .tertiary:
            return .green
        }
    }

    init(colorIndex: Int) {
        if let color = SupportColor(rawValue: colorIndex) {
            self = color
        } else {
            self = .primary
        }
    }
}
