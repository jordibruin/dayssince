//
//  Date+Extensions.swift
//  DaysSince
//
//  Created by Vicki Minerva on 2/22/24.
//

import Foundation

extension Date {
    var dayBefore: Date {
        return Calendar.current.date(byAdding: .day, value: -1, to: self)!
    }
}
