@testable import DaysSince
import Foundation
import Testing

@Suite("Date.dayBefore")
struct DateExtensionTests {
    let calendar = Calendar.current

    @Test("mid-month date steps back one day")
    func dayBefore() {
        var components = DateComponents()
        components.year = 2024
        components.month = 3
        components.day = 15

        let date = calendar.date(from: components)!
        let dayBefore = date.dayBefore

        let dayBeforeComponents = calendar.dateComponents([.year, .month, .day], from: dayBefore)
        #expect(dayBeforeComponents.year == 2024)
        #expect(dayBeforeComponents.month == 3)
        #expect(dayBeforeComponents.day == 14)
    }

    @Test("first of month steps back into the previous month")
    func dayBeforeFirstOfMonth() {
        var components = DateComponents()
        components.year = 2024
        components.month = 3
        components.day = 1

        let date = calendar.date(from: components)!
        let dayBefore = date.dayBefore

        let dayBeforeComponents = calendar.dateComponents([.year, .month, .day], from: dayBefore)
        #expect(dayBeforeComponents.year == 2024)
        #expect(dayBeforeComponents.month == 2)
        #expect(dayBeforeComponents.day == 29, "2024 is a leap year")
    }

    @Test("first of year steps back into the previous year")
    func dayBeforeFirstOfYear() {
        var components = DateComponents()
        components.year = 2024
        components.month = 1
        components.day = 1

        let date = calendar.date(from: components)!
        let dayBefore = date.dayBefore

        let dayBeforeComponents = calendar.dateComponents([.year, .month, .day], from: dayBefore)
        #expect(dayBeforeComponents.year == 2023)
        #expect(dayBeforeComponents.month == 12)
        #expect(dayBeforeComponents.day == 31)
    }

    @Test("dayBefore is exactly one day before today")
    func dayBeforeIsExactlyOneDayApart() {
        let today = Date.now
        let dayBefore = today.dayBefore
        let days = calendar.numberOfDaysBetween(dayBefore, and: today)
        #expect(days == 1)
    }
}
