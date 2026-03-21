//
//  Calendar+Extensions.swift
//  DaysSince
//
//  Created by Vicki Minerva on 3/30/22.
//

import Foundation

extension Calendar {
    func numberOfDaysBetween(_ from: Date, and to: Date) -> Int {
        let fromDate = startOfDay(for: from) // <1>
        let toDate = startOfDay(for: to) // <2>
        let numberOfDays = dateComponents([.day], from: fromDate, to: toDate) // <3>

        return numberOfDays.day!
    }
    
    static func daysAgo(_ days: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: -days, to: Date())!
    }

    static func yearsAgo(_ years: Int) -> Date {
        Calendar.current.date(byAdding: .year, value: -years, to: Date())!
    }
}
