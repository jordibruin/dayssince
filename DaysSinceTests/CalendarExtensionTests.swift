@testable import DaysSince
import Foundation
import Testing

@Suite("Calendar.numberOfDaysBetween")
struct CalendarExtensionTests {
    let calendar = Calendar.current

    // MARK: - Number of Days Between

    @Test("same date is zero days apart")
    func sameDay() {
        let date = Date.now
        let days = calendar.numberOfDaysBetween(date, and: date)
        #expect(days == 0)
    }

    /// Table collapses the former one/seven/thirty/365-day and negative-day tests.
    /// `offsetDays` is applied to "now" with `Calendar.current`, then compared
    /// against "now" — preserving the original (relative-to-today) behavior.
    @Test(
        "day offsets from today produce the expected delta",
        arguments: zip(
            [-1, -7, -30, -365, 1],
            [1, 7, 30, 365, -1]
        )
    )
    func dayDelta(offsetDays: Int, expectedDays: Int) {
        let today = Date.now
        let other = calendar.date(byAdding: .day, value: offsetDays, to: today)!
        let days = calendar.numberOfDaysBetween(other, and: today)
        #expect(days == expectedDays)
    }

    @Test("two fixed dates in the same month")
    func specificDates() {
        var components1 = DateComponents()
        components1.year = 2024
        components1.month = 1
        components1.day = 1

        var components2 = DateComponents()
        components2.year = 2024
        components2.month = 1
        components2.day = 15

        let date1 = calendar.date(from: components1)!
        let date2 = calendar.date(from: components2)!

        let days = calendar.numberOfDaysBetween(date1, and: date2)
        #expect(days == 14)
    }

    @Test("time of day is ignored")
    func ignoresTimeComponent() {
        let todayMorning = calendar.startOfDay(for: Date.now)
        let todayEvening = calendar.date(byAdding: .hour, value: 23, to: todayMorning)!
        let days = calendar.numberOfDaysBetween(todayMorning, and: todayEvening)
        #expect(days == 0, "Time of day should not affect the day count")
    }

    @Test("crosses a month boundary")
    func crossMonthBoundary() {
        var jan31 = DateComponents()
        jan31.year = 2024
        jan31.month = 1
        jan31.day = 31

        var feb1 = DateComponents()
        feb1.year = 2024
        feb1.month = 2
        feb1.day = 1

        let date1 = calendar.date(from: jan31)!
        let date2 = calendar.date(from: feb1)!

        let days = calendar.numberOfDaysBetween(date1, and: date2)
        #expect(days == 1)
    }

    @Test("counts the leap day in 2024")
    func leapYear() {
        var feb28 = DateComponents()
        feb28.year = 2024
        feb28.month = 2
        feb28.day = 28

        var mar1 = DateComponents()
        mar1.year = 2024
        mar1.month = 3
        mar1.day = 1

        let date1 = calendar.date(from: feb28)!
        let date2 = calendar.date(from: mar1)!

        let days = calendar.numberOfDaysBetween(date1, and: date2)
        #expect(days == 2, "2024 is a leap year, Feb has 29 days")
    }
}
