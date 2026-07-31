@testable import DaysSince
import Foundation
import Testing
import UserNotifications

/// Pure tier — the builder takes an explicit calendar, so nothing here reads
/// `Calendar.current` or `UserDefaults`.
@Suite("Reminder request builder")
struct ReminderRequestBuilderTests {

    private let calendar = Fixtures.gmtCalendar

    // MARK: - Time of day

    @Test("reminders are hardcoded to 10:00")
    func hardcodedTime() {
        #expect(ReminderRequestBuilder.defaultHour == 10)
        #expect(ReminderRequestBuilder.defaultMinute == 0)
    }

    @Test("every repeating cadence fires at 10:00", arguments: [DSItemReminders.daily, .weekly, .monthly])
    func everyCadenceFiresAtTen(reminder: DSItemReminders) throws {
        let components = try #require(
            ReminderRequestBuilder.dateComponents(for: Fixtures.item(reminder: reminder), calendar: calendar)
        )

        #expect(components.hour == 10)
        #expect(components.minute == 0)
    }

    @Test("the trigger resolves in the calendar's time zone, not the device's")
    func componentsCarryCalendarTimeZone() throws {
        let components = try #require(
            ReminderRequestBuilder.dateComponents(for: Fixtures.item(), calendar: calendar)
        )

        #expect(components.timeZone == calendar.timeZone)
        #expect(components.calendar == calendar)
    }

    // MARK: - Cadence

    @Test("a daily reminder matches on time of day only")
    func dailyMatchesTimeOnly() throws {
        let components = try #require(
            ReminderRequestBuilder.dateComponents(for: Fixtures.item(reminder: .daily), calendar: calendar)
        )

        #expect(components.weekday == nil)
        #expect(components.day == nil)
        #expect(components.month == nil)
    }

    @Test("a weekly reminder repeats on the weekday of dateLastDone")
    func weeklyUsesWeekday() throws {
        // 1970-01-12 was a Monday, which is weekday 2 in the Gregorian calendar.
        let item = Fixtures.item(dateLastDone: Fixtures.referenceDate, reminder: .weekly)

        let components = try #require(ReminderRequestBuilder.dateComponents(for: item, calendar: calendar))

        #expect(components.weekday == 2)
        #expect(components.day == nil)
    }

    @Test("every weekday round trips", arguments: 1 ... 7)
    func weeklyCoversEveryWeekday(weekday: Int) throws {
        // 1970-01-11 was a Sunday (weekday 1), so adding n days walks the week.
        let sunday = try #require(calendar.date(from: DateComponents(year: 1970, month: 1, day: 11)))
        let date = try #require(calendar.date(byAdding: .day, value: weekday - 1, to: sunday))
        let item = Fixtures.item(dateLastDone: date, reminder: .weekly)

        let components = try #require(ReminderRequestBuilder.dateComponents(for: item, calendar: calendar))

        #expect(components.weekday == weekday)
    }

    @Test("a monthly reminder repeats on the day of month of dateLastDone")
    func monthlyUsesDayOfMonth() throws {
        let item = Fixtures.item(dateLastDone: Fixtures.referenceDate, reminder: .monthly)

        let components = try #require(ReminderRequestBuilder.dateComponents(for: item, calendar: calendar))

        #expect(components.day == 12)
        #expect(components.weekday == nil)
    }

    /// Day 29/30/31 are still emitted verbatim — `UNCalendarNotificationTrigger` simply
    /// skips months without that day. Pinned so nobody "fixes" it into a clamp.
    @Test("a day-of-month past the shortest month is kept verbatim", arguments: [29, 30, 31])
    func monthlyKeepsHighDayNumbers(day: Int) throws {
        let date = try #require(calendar.date(from: DateComponents(year: 2024, month: 1, day: day)))
        let item = Fixtures.item(dateLastDone: date, reminder: .monthly)

        let components = try #require(ReminderRequestBuilder.dateComponents(for: item, calendar: calendar))

        #expect(components.day == day)
    }

    @Test("a leap day reminder repeats on the 29th")
    func leapDayUsesTwentyNinth() throws {
        let date = try #require(calendar.date(from: DateComponents(year: 2024, month: 2, day: 29)))
        let item = Fixtures.item(dateLastDone: date, reminder: .monthly)

        let components = try #require(ReminderRequestBuilder.dateComponents(for: item, calendar: calendar))

        #expect(components.day == 29)
    }

    /// A DST transition moves the wall clock, not the calendar date, so the components
    /// must be identical either side of it.
    @Test("a DST transition does not shift the reminder")
    func dstDoesNotShiftComponents() throws {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = try #require(TimeZone(identifier: "Europe/Amsterdam"))
        // 2024-03-31 is the spring-forward date in Amsterdam.
        let springForward = try #require(calendar.date(from: DateComponents(year: 2024, month: 3, day: 31, hour: 12)))
        let dayBefore = try #require(calendar.date(byAdding: .day, value: -1, to: springForward))

        let after = try #require(
            ReminderRequestBuilder.dateComponents(
                for: Fixtures.item(dateLastDone: springForward, reminder: .monthly),
                calendar: calendar
            )
        )
        let before = try #require(
            ReminderRequestBuilder.dateComponents(
                for: Fixtures.item(dateLastDone: dayBefore, reminder: .monthly),
                calendar: calendar
            )
        )

        #expect(after.hour == 10)
        #expect(before.hour == 10)
        #expect(after.day == 31)
        #expect(before.day == 30)
    }

    @Test("a reminder of none produces no components")
    func noneProducesNoComponents() {
        #expect(ReminderRequestBuilder.dateComponents(for: Fixtures.item(reminder: .none), calendar: calendar) == nil)
    }

    // MARK: - Content

    @Test(
        "each cadence gets its own body copy",
        arguments: [
            (DSItemReminders.daily, "One more day since Dentist!"),
            (.weekly, "It's been another week since Dentist!"),
            (.monthly, "It's been another month since Dentist!"),
        ]
    )
    func bodyCopyPerCadence(reminder: DSItemReminders, expected: String) throws {
        let content = try #require(ReminderRequestBuilder.content(for: Fixtures.item(name: "Dentist", reminder: reminder)))

        #expect(content.title == "Dentist")
        #expect(content.body == expected)
        #expect(content.sound != nil)
    }

    @Test("a reminder of none produces no content")
    func noneProducesNoContent() {
        #expect(ReminderRequestBuilder.content(for: Fixtures.item(reminder: .none)) == nil)
    }

    // MARK: - Requests

    @Test("a repeating cadence produces one request identified by the item's notification ID")
    func requestIdentifierIsNotificationID() throws {
        let item = Fixtures.item(name: "Dentist", reminder: .weekly, reminderNotificationID: "abc-123")

        let requests = ReminderRequestBuilder.requests(for: item, calendar: calendar)

        #expect(requests.count == 1)
        let request = try #require(requests.first)
        #expect(request.identifier == "abc-123")
        #expect(request.content.title == "Dentist")
    }

    @Test("the request repeats", arguments: [DSItemReminders.daily, .weekly, .monthly])
    func requestsRepeat(reminder: DSItemReminders) throws {
        let requests = ReminderRequestBuilder.requests(for: Fixtures.item(reminder: reminder), calendar: calendar)

        let trigger = try #require(requests.first?.trigger as? UNCalendarNotificationTrigger)
        #expect(trigger.repeats)
        #expect(trigger.dateComponents.hour == 10)
    }

    @Test("a reminder of none produces no requests")
    func noneProducesNoRequests() {
        #expect(ReminderRequestBuilder.requests(for: Fixtures.item(reminder: .none), calendar: calendar).isEmpty)
    }

    // MARK: - Identifier matching

    @Test("matching finds the item's own identifier and its historical suffixed ones")
    func matchingFindsSuffixedIdentifiers() {
        let item = Fixtures.item(reminderNotificationID: "event-1")

        let matched = ReminderRequestBuilder.identifiers(
            matching: item,
            in: ["event-1", "event-10", "event-1-2", "other", ""]
        )

        #expect(matched == ["event-1", "event-10", "event-1-2"])
    }

    /// Prefix matching means one event can delete another event's reminder when its ID is
    /// a prefix of the other. Real IDs are UUIDs, so this cannot happen in production —
    /// the test exists so that changing the identifier scheme to something non-UUID
    /// surfaces the hazard instead of silently deleting reminders.
    @Test("prefix matching can collide across events")
    func prefixMatchingCollides() {
        let short = Fixtures.item(reminderNotificationID: "1")
        let long = Fixtures.item(reminderNotificationID: "12")

        #expect(ReminderRequestBuilder.identifiers(matching: short, in: [long.reminderNotificationID]) == ["12"])
        #expect(ReminderRequestBuilder.identifiers(matching: long, in: [short.reminderNotificationID]).isEmpty)
    }

    @Test("matching against no pending identifiers finds nothing")
    func matchingEmptyList() {
        #expect(ReminderRequestBuilder.identifiers(matching: Fixtures.item(), in: []).isEmpty)
    }

    @Test("a real UUID identifier does not match an unrelated one")
    func uuidsDoNotCollide() {
        let a = Fixtures.item()
        let b = Fixtures.item()

        #expect(ReminderRequestBuilder.identifiers(matching: a, in: [b.reminderNotificationID]).isEmpty)
    }
}
