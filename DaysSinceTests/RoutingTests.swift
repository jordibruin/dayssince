@testable import DaysSince
import Foundation
import Testing

/// The launch-routing table from CLAUDE.md. Getting a row wrong sends a user with data back
/// through onboarding — which then overwrites `Defaults[.categories]` — so each row is pinned.
@Suite("App routing")
struct RoutingTests {

    // MARK: - The four documented states

    @Test(
        "each documented launch state lands on the right screen",
        arguments: [
            // hasSeenOnboarding, iCloudMigrationComplete, expected
            (false, false, AppRoute.onboarding), // new user
            (true, false, AppRoute.iCloudMigration), // existing user, first iCloud launch
            (false, true, AppRoute.onboarding), // reinstall: startSync restored from iCloud
            (true, true, AppRoute.main), // normal launch
        ]
    )
    func routeTable(hasSeenOnboarding: Bool, iCloudMigrationComplete: Bool, expected: AppRoute) {
        #expect(
            AppRoute.route(
                hasSeenOnboarding: hasSeenOnboarding,
                iCloudMigrationComplete: iCloudMigrationComplete
            ) == expected
        )
    }

    @Test("onboarding takes precedence over a completed migration")
    func onboardingWinsOverMigration() {
        // The reinstall case: iCloud restored the data, but UserDefaults (and therefore
        // hasSeenOnboarding) was wiped with the app.
        #expect(
            AppRoute.route(hasSeenOnboarding: false, iCloudMigrationComplete: true)
                == .onboarding
        )
    }

    @Test("migration is never shown to someone who has not onboarded")
    func migrationRequiresOnboarding() {
        for iCloudMigrationComplete in [true, false] {
            #expect(
                AppRoute.route(
                    hasSeenOnboarding: false,
                    iCloudMigrationComplete: iCloudMigrationComplete
                ) != .iCloudMigration
            )
        }
    }

    // MARK: - Paywall

    @Test("the paywall is offered exactly once")
    func paywallShownOnce() {
        #expect(AppRoute.shouldShowPaywall(hasSeenPaywall: false))
        #expect(!AppRoute.shouldShowPaywall(hasSeenPaywall: true))
    }

    // MARK: - Legacy migration dead path

    /// `ContentView` declares `@AppStorage("items") var oldItems: [oldDSItem]` against the very
    /// key that current items live under, so the legacy migration can only ever see `[]`. It is
    /// dead by construction; this pins that so a future cleanup can delete it with confidence,
    /// and so nobody "fixes" the decode and starts duplicating every event.
    @Test("the legacy migration cannot decode current items")
    func legacyMigrationNeverFires() throws {
        let current = [
            Fixtures.item(name: "Haircut"),
            Fixtures.item(name: "Dentist"),
        ]

        let stored = current.rawValue // exactly what @AppStorage writes

        #expect([DSItem](rawValue: stored)?.count == 2)
        #expect([oldDSItem](rawValue: stored) == nil)
    }

    @Test("a legacy payload does decode, confirming the pin is about the shared key")
    func legacyPayloadStillDecodable() throws {
        let legacy = [
            oldDSItem(
                id: UUID(),
                name: "Haircut",
                dateLastDone: Fixtures.referenceDate,
                remindersEnabled: false
            ),
        ]

        let decoded = try #require([oldDSItem](rawValue: legacy.rawValue))

        #expect(decoded.count == 1)
        #expect(decoded.first?.name == "Haircut")
    }
}
