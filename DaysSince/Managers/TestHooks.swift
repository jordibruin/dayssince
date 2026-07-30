//
//  TestHooks.swift
//  DaysSince
//

import Foundation

/// Launch-argument overrides for the XCUITest suite. Every hook is inert outside DEBUG, so
/// call sites need no `#if DEBUG` of their own.
///
/// `-uiTest` is deliberately one coarse flag rather than a set of fine-grained ones: a suite
/// that forgets to pass "no network" or "stub permissions" doesn't fail loudly, it just gets
/// flaky. Individual flags exist only for things a test genuinely varies.
enum TestHooks {

    // MARK: - Flags

    /// A UI test run: state is reset at launch, iCloud is in-memory, no network calls are made,
    /// and no system permission prompt is shown.
    static var isUITest: Bool { isSet("-uiTest") }

    /// The once-per-install paywall is *off* by default under `-uiTest` and opted back in with
    /// `-showPaywall`. Inverted deliberately: almost every suite needs to reach the main screen,
    /// and only one is about the paywall itself.
    static var introPaywallSuppressed: Bool { isUITest && !isSet("-showPaywall") }

    /// `UITEST_SUBSCRIBED=1` forces Pro on, `=0` forces it off. `nil` means "ask StoreKit".
    static var forcedSubscription: Bool? {
        guard let raw = environmentValue("UITEST_SUBSCRIBED") else { return nil }
        return raw == "1"
    }

    static var animationsDisabled: Bool { isUITest }

    /// Skips `UNUserNotificationCenter.requestAuthorization`, whose system alert is outside the
    /// app and would block any test that schedules a reminder.
    static var notificationPromptSuppressed: Bool { isUITest }

    static var networkDisabled: Bool { isUITest }

    /// StoreKit's rating alert is a system presentation that would swallow every subsequent tap,
    /// and it fires from any sheet dismissal — including the category sheets several suites use.
    static var reviewPromptSuppressed: Bool { isUITest }

    /// A relaunch *within* one test has to keep what the previous launch wrote, or nothing about
    /// persistence can be asserted. Opt-in, because a clean slate has to stay the default.
    static var stateResetSuppressed: Bool { isSet("-keepState") }

    // MARK: - iCloud

    /// UI tests must never reach the real `NSUbiquitousKeyValueStore`: it would restore state
    /// the reset just cleared, and it would push test events into the developer's own iCloud
    /// account. Clearing the live store instead is not an option — it holds real user data.
    static func makeICloudStore() -> KeyValueStoreProtocol {
        #if DEBUG
        if isUITest { return InMemoryKeyValueStore() }
        #endif
        return NSUbiquitousKeyValueStore.default
    }

    // MARK: - Reset

    /// Wipes everything a previous run could have left behind. Must happen before any manager
    /// reads storage, so call it as the first statement of `DaysSinceApp.init()`.
    static func resetStateIfRequested() {
        #if DEBUG
        guard isUITest, !stateResetSuppressed else { return }

        for key in standardKeys {
            UserDefaults.standard.removeObject(forKey: key)
        }
        for key in appGroupKeys {
            appGroupDefaults?.removeObject(forKey: key)
        }
        #endif
    }

    #if DEBUG

    /// Enumerated rather than wiping the whole domain: `removePersistentDomain` does not
    /// reliably clear values already cached by the running process, and a launch-time reset
    /// that only mostly works is worse than none.
    private static let standardKeys = [
        "hasSeenOnboarding",
        "iCloudMigrationComplete",
        "migratedFromOld",
        "hasSeenPaywall",
        "selectedSortType",
        CategoryStore.key,
        "mainColor",
        "backgroundColor",
        "selectedThemeId",
        ReviewManager.lastAskedVersionKey,
    ]

    private static let appGroupKeys = [
        DataSyncManager.itemsKey,
        DataSyncManager.categoriesKey,
        "isDaysDisplayModeDetailed",
        "dayssince_subscribed",
    ]

    private static var appGroupDefaults: UserDefaults? {
        UserDefaults(suiteName: "group.goodsnooze.dayssince")
    }

    private static func isSet(_ flag: String) -> Bool {
        CommandLine.arguments.contains(flag)
    }

    private static func environmentValue(_ name: String) -> String? {
        ProcessInfo.processInfo.environment[name]
    }

    #else

    private static func isSet(_: String) -> Bool { false }
    private static func environmentValue(_: String) -> String? { nil }

    #endif
}

#if DEBUG
/// Stands in for `NSUbiquitousKeyValueStore` during UI tests.
private final class InMemoryKeyValueStore: KeyValueStoreProtocol {
    private var storage: [String: Any] = [:]

    func data(forKey key: String) -> Data? { storage[key] as? Data }

    func set(_ value: Any?, forKey key: String) { storage[key] = value }

    func synchronize() -> Bool { true }
}
#endif
