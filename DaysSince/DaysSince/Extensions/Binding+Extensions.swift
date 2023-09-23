//
//  Binding+Extensions.swift
//  DaysSince
//
//  Created by Vicki Minerva on 5/27/22.
//

import Foundation
import SwiftUI

extension Binding {
    var optional: Binding<Value?> {
        Binding<Value?>(
            get: { self.wrappedValue },
            set: {
                guard let value = $0 else { return }
                self.wrappedValue = value
            }
        )
    }
}
