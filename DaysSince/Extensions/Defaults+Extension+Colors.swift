//
//  Defaults+Extension+Colors.swift
//  DaysSince
//
//  Created by Vicki Minerva on 9/24/23.
//

import Defaults
import Foundation
import SwiftUI

extension Defaults.Keys {
    static let mainColor = Key<Color>("mainColor", default: Color.workColor)
    static let backgroundColor = Key<Color>("backgroundColor", default: Color.backgroundColor)
}
