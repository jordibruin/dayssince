@testable import DaysSince
import XCTest

final class CalendarExtensionTests: XCTestCase {
    let calendar = Calendar.current

    // MARK: - Number of Days Between

    func testSameDay() {
        let date = Date.now
        let days = calendar.numberOfDaysBetween(date, and: date)
        XCTAssertEqual(days, 0)
    }

    func testOneDayApart() {
        let today = Date.now
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
        let days = calendar.numberOfDaysBetween(yesterday, and: today)
        XCTAssertEqual(days, 1)
    }

    func testSevenDaysApart() {
        let today = Date.now
        let weekAgo = calendar.date(byAdding: .day, value: -7, to: today)!
        let days = calendar.numberOfDaysBetween(weekAgo, and: today)
        XCTAssertEqual(days, 7)
    }

    func testThirtyDaysApart() {
        let today = Date.now
        let monthAgo = calendar.date(byAdding: .day, value: -30, to: today)!
        let days = calendar.numberOfDaysBetween(monthAgo, and: today)
        XCTAssertEqual(days, 30)
    }

    func testYearApart() {
        let today = Date.now
        let yearAgo = calendar.date(byAdding: .day, value: -365, to: today)!
        let days = calendar.numberOfDaysBetween(yearAgo, and: today)
        XCTAssertEqual(days, 365)
    }

    func testNegativeDays() {
        let today = Date.now
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: today)!
        let days = calendar.numberOfDaysBetween(tomorrow, and: today)
        XCTAssertEqual(days, -1)
    }

    func testSpecificDates() {
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
        XCTAssertEqual(days, 14)
    }

    func testIgnoresTimeComponent() {
        let todayMorning = calendar.startOfDay(for: Date.now)
        let todayEvening = calendar.date(byAdding: .hour, value: 23, to: todayMorning)!
        let days = calendar.numberOfDaysBetween(todayMorning, and: todayEvening)
        XCTAssertEqual(days, 0, "Time of day should not affect the day count")
    }

    func testCrossMonthBoundary() {
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
        XCTAssertEqual(days, 1)
    }

    func testLeapYear() {
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
        XCTAssertEqual(days, 2, "2024 is a leap year, Feb has 29 days")
    }
}
