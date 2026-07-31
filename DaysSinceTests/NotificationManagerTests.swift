@testable import DaysSince
import Foundation
import Testing
import UserNotifications

/// Injected tier — the manager takes a scheduler and its App Group defaults, so nothing
/// here touches `UNUserNotificationCenter` or `UserDefaults.standard`.
@Suite("Notification manager")
struct NotificationManagerTests {

    /// Held for the lifetime of the test: its `deinit` removes the persistent domain.
    private let isolated = IsolatedDefaults()

    private func makeManager(
        _ scheduler: MockNotificationScheduler,
        autoRefresh: Bool = false
    ) -> NotificationManager {
        NotificationManager(scheduler: scheduler, appGroupDefaults: isolated.defaults, autoRefresh: autoRefresh)
    }

    private func seedAppGroup(_ items: [DSItem]) throws {
        let json = try #require(String(data: try JSONEncoder().encode(items), encoding: .utf8))
        isolated.defaults.set(json, forKey: "items")
    }

    // MARK: - Init

    @Test("init without auto refresh leaves the scheduler untouched")
    func autoRefreshOff() {
        let scheduler = MockNotificationScheduler()

        _ = makeManager(scheduler)

        #expect(scheduler.calls.isEmpty)
    }

    @Test("init refreshes from the App Group store")
    func initRefreshesFromAppGroup() throws {
        try seedAppGroup([Fixtures.item(name: "Dentist", remindersEnabled: true, reminderNotificationID: "dentist")])
        let scheduler = MockNotificationScheduler()

        _ = makeManager(scheduler, autoRefresh: true)

        #expect(scheduler.removeAllCount == 1)
        #expect(scheduler.addedIdentifiers == ["dentist"])
    }

    /// Items are written as JSON strings, but the manager also falls back to `Data` —
    /// pinned because the fallback is the only reason a `Data`-written payload survives.
    @Test("init falls back to a Data-encoded payload")
    func initReadsDataEncodedItems() throws {
        let items = [Fixtures.item(remindersEnabled: true, reminderNotificationID: "data")]
        isolated.defaults.set(try JSONEncoder().encode(items), forKey: "items")
        let scheduler = MockNotificationScheduler()

        _ = makeManager(scheduler, autoRefresh: true)

        #expect(scheduler.addedIdentifiers == ["data"])
    }

    @Test("init with no stored items schedules nothing but still clears pending")
    func initWithNoItems() {
        let scheduler = MockNotificationScheduler(pending: [MockNotificationScheduler.request(identifier: "stale")])

        _ = makeManager(scheduler, autoRefresh: true)

        #expect(scheduler.removeAllCount == 1)
        #expect(scheduler.added.isEmpty)
        #expect(scheduler.pendingIdentifiers.isEmpty)
    }

    @Test("init with garbage stored items does not crash or schedule")
    func initWithGarbage() {
        isolated.defaults.set("not json", forKey: "items")
        let scheduler = MockNotificationScheduler()

        _ = makeManager(scheduler, autoRefresh: true)

        #expect(scheduler.added.isEmpty)
    }

    // MARK: - Refresh

    @Test("refresh schedules only items with reminders enabled")
    func refreshSkipsDisabledItems() {
        let scheduler = MockNotificationScheduler()
        let manager = makeManager(scheduler)

        manager.refreshNotifications(items: [
            Fixtures.item(name: "On", remindersEnabled: true, reminderNotificationID: "on"),
            Fixtures.item(name: "Off", remindersEnabled: false, reminderNotificationID: "off"),
        ])

        #expect(scheduler.addedIdentifiers == ["on"])
    }

    @Test("refresh skips an enabled item whose cadence is none")
    func refreshSkipsNoneCadence() {
        let scheduler = MockNotificationScheduler()
        let manager = makeManager(scheduler)

        manager.refreshNotifications(items: [
            Fixtures.item(remindersEnabled: true, reminder: .none, reminderNotificationID: "none"),
        ])

        #expect(scheduler.added.isEmpty)
    }

    @Test("refresh clears everything before scheduling")
    func refreshClearsFirst() {
        let scheduler = MockNotificationScheduler()
        let manager = makeManager(scheduler)

        manager.refreshNotifications(items: [
            Fixtures.item(remindersEnabled: true, reminderNotificationID: "a"),
            Fixtures.item(remindersEnabled: true, reminderNotificationID: "b"),
        ])

        #expect(scheduler.calls.first == .removeAll)
        #expect(scheduler.removeAllCount == 1)
        #expect(scheduler.addedIdentifiers == ["a", "b"])
    }

    @Test("refresh replaces the previous schedule rather than accumulating")
    func refreshReplacesPreviousSchedule() {
        let scheduler = MockNotificationScheduler()
        let manager = makeManager(scheduler)
        let first = Fixtures.item(remindersEnabled: true, reminderNotificationID: "first")
        let second = Fixtures.item(remindersEnabled: true, reminderNotificationID: "second")

        manager.refreshNotifications(items: [first])
        manager.refreshNotifications(items: [second])

        #expect(scheduler.pendingIdentifiers == ["second"])
    }

    // MARK: - Authorization

    @Test("an authorized add replaces the item's own pending request")
    func authorizedAddDedupes() {
        let scheduler = MockNotificationScheduler(pending: [MockNotificationScheduler.request(identifier: "dentist")])
        let manager = makeManager(scheduler)

        manager.addReminderFor(item: Fixtures.item(remindersEnabled: true, reminderNotificationID: "dentist"))

        #expect(scheduler.removedIdentifiers == [["dentist"]])
        #expect(scheduler.pendingIdentifiers == ["dentist"])
        #expect(scheduler.authorizationRequestCount == 0)
    }

    @Test(
        "an unauthorized add asks for permission first",
        arguments: [NotificationAuthorization.notDetermined, .denied, .provisional, .ephemeral]
    )
    func unauthorizedAddRequestsPermission(authorization: NotificationAuthorization) {
        let scheduler = MockNotificationScheduler(authorization: authorization)
        let manager = makeManager(scheduler)

        manager.addReminderFor(item: Fixtures.item(remindersEnabled: true, reminderNotificationID: "dentist"))

        #expect(scheduler.authorizationRequestCount == 1)
        #expect(scheduler.addedIdentifiers == ["dentist"])
    }

    @Test("a denied permission request schedules nothing")
    func deniedPermissionSchedulesNothing() {
        let scheduler = MockNotificationScheduler(authorization: .denied, authorizationGranted: false)
        let manager = makeManager(scheduler)

        manager.addReminderFor(item: Fixtures.item(remindersEnabled: true))

        #expect(scheduler.authorizationRequestCount == 1)
        #expect(scheduler.added.isEmpty)
    }

    @Test("a refresh while denied asks once per item and schedules nothing")
    func refreshWhileDenied() {
        let scheduler = MockNotificationScheduler(authorization: .denied, authorizationGranted: false)
        let manager = makeManager(scheduler)

        manager.refreshNotifications(items: [
            Fixtures.item(remindersEnabled: true),
            Fixtures.item(remindersEnabled: true),
        ])

        #expect(scheduler.authorizationRequestCount == 2)
        #expect(scheduler.added.isEmpty)
    }

    @Test("granting permission schedules the items requested after it")
    func schedulingResumesAfterAuthorization() {
        let scheduler = MockNotificationScheduler(authorization: .denied, authorizationGranted: true)
        let manager = makeManager(scheduler)

        manager.addReminderFor(item: Fixtures.item(remindersEnabled: true, reminderNotificationID: "first"))
        manager.addReminderFor(item: Fixtures.item(remindersEnabled: true, reminderNotificationID: "second"))

        // The grant flips the status, so only the first add has to ask.
        #expect(scheduler.authorizationRequestCount == 1)
        #expect(scheduler.addedIdentifiers == ["first", "second"])
    }

    @Test("an item with no cadence never reaches the scheduler")
    func noneCadenceSkipsAuthorizationCheck() {
        let scheduler = MockNotificationScheduler()
        let manager = makeManager(scheduler)

        manager.addReminderFor(item: Fixtures.item(remindersEnabled: true, reminder: .none))

        #expect(scheduler.calls.isEmpty)
    }

    // MARK: - Delete

    @Test("delete removes only the item's own pending requests")
    func deleteRemovesOnlyMatchingPrefixes() {
        let scheduler = MockNotificationScheduler(pending: [
            MockNotificationScheduler.request(identifier: "dentist"),
            MockNotificationScheduler.request(identifier: "dentist1"),
            MockNotificationScheduler.request(identifier: "gym"),
        ])
        let manager = makeManager(scheduler)

        manager.deleteReminderFor(item: Fixtures.item(reminderNotificationID: "dentist"))

        #expect(scheduler.pendingIdentifiers == ["gym"])
    }

    @Test("deleting an item with nothing pending leaves the schedule alone")
    func deleteWithNoMatches() {
        let scheduler = MockNotificationScheduler(pending: [MockNotificationScheduler.request(identifier: "gym")])
        let manager = makeManager(scheduler)

        manager.deleteReminderFor(item: Fixtures.item(reminderNotificationID: "dentist"))

        #expect(scheduler.pendingIdentifiers == ["gym"])
    }

    @Test("deleting one item does not disturb another")
    func deleteIsScopedToOneItem() {
        let scheduler = MockNotificationScheduler()
        let manager = makeManager(scheduler)
        let kept = Fixtures.item(remindersEnabled: true, reminderNotificationID: "kept")
        let removed = Fixtures.item(remindersEnabled: true, reminderNotificationID: "removed")

        manager.refreshNotifications(items: [kept, removed])
        manager.deleteReminderFor(item: removed)

        #expect(scheduler.pendingIdentifiers == ["kept"])
    }
}
