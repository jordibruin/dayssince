//
//  UIApplication+Extensions.swift
//  DaysSince
//
//  Created by Saurabh Jamadagni on 03/03/23.
//

import SwiftUI

extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
