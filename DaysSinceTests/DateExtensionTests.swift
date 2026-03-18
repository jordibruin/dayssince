@testable import DaysSince
import XCTest

final class DateExtensionTests: XCTestCase {
    let calendar = Calendar.current

    func testDayBefore() {
        var components = DateComponents()
        components.year = 2024
        components.month = 3
        components.day = 15

        let date = calendar.date(from: components)!
        let dayBefore = date.dayBefore

        let dayBeforeComponents = calendar.dateComponents([.year, .month, .day], from: dayBefore)
        XCTAssertEqual(dayBeforeComponents.year, 2024)
        XCTAssertEqual(dayBeforeComponents.month, 3)
        XCTAssertEqual(dayBeforeComponents.day, 14)
    }

    func testDayBeforeFirstOfMonth() {
        var components = DateComponents()
        components.year = 2024
        components.month = 3
        components.day = 1

        let date = calendar.date(from: components)!
        let dayBefore = date.dayBefore

        let dayBeforeComponents = calendar.dateComponents([.year, .month, .day], from: dayBefore)
        XCTAssertEqual(dayBeforeComponents.year, 2024)
        XCTAssertEqual(dayBeforeComponents.month, 2)
        XCTAssertEqual(dayBeforeComponents.day, 29, "2024 is a leap year")
    }

    func testDayBeforeFirstOfYear() {
        var components = DateComponents()
        components.year = 2024
        components.month = 1
        components.day = 1

        let date = calendar.date(from: components)!
        let dayBefore = date.dayBefore

        let dayBeforeComponents = calendar.dateComponents([.year, .month, .day], from: dayBefore)
        XCTAssertEqual(dayBeforeComponents.year, 2023)
        XCTAssertEqual(dayBeforeComponents.month, 12)
        XCTAssertEqual(dayBeforeComponents.day, 31)
    }

    func testDayBeforeIsExactlyOneDayApart() {
        let today = Date.now
        let dayBefore = today.dayBefore
        let days = calendar.numberOfDaysBetween(dayBefore, and: today)
        XCTAssertEqual(days, 1)
    }
}
