@testable import DaysSince
import Foundation
import Testing

/// Injected tier. `applyEntitlement` is the only place entitlement reaches storage, and the
/// key it writes is a cross-target contract: the widgets gate Pro features on it without
/// linking StoreKit. StoreKit itself is never touched here — see `SubscriptionStoreKitTests`.
@Suite("Subscription entitlement")
@MainActor
struct SubscriptionEntitlementTests {

    private let isolated = IsolatedDefaults()

    /// The literal is repeated rather than referenced so that renaming the key in
    /// `SubscriptionManager` fails here, instead of silently leaving the widgets locked.
    private let widgetKey = "dayssince_subscribed"

    private func makeManager(sharedDefaults: UserDefaults?) -> SubscriptionManager {
        SubscriptionManager(
            sharedDefaults: sharedDefaults,
            notifier: SpyPurchaseNotifier(),
            autoStart: false
        )
    }

    @Test("an active entitlement mirrors true to the App Group key the widgets read")
    func activeEntitlementMirrors() {
        let manager = makeManager(sharedDefaults: isolated.defaults)

        manager.applyEntitlement(hasActive: true)

        #expect(manager.isSubscribed)
        #expect(isolated.defaults.bool(forKey: widgetKey))
    }

    @Test("losing the entitlement writes false rather than removing the key")
    func lostEntitlementClears() {
        let manager = makeManager(sharedDefaults: isolated.defaults)
        manager.applyEntitlement(hasActive: true)

        manager.applyEntitlement(hasActive: false)

        #expect(!manager.isSubscribed)
        #expect(isolated.defaults.object(forKey: widgetKey) as? Bool == false)
    }

    @Test("a manager built with autoStart false leaves the mirror untouched")
    func autoStartFalseWritesNothing() {
        let manager = makeManager(sharedDefaults: isolated.defaults)

        #expect(!manager.isSubscribed)
        #expect(manager.activeTransaction == nil)
        #expect(manager.products.isEmpty)
        #expect(!manager.isEligibleForIntro)
        #expect(isolated.defaults.object(forKey: widgetKey) == nil)
    }

    @Test("applying the same entitlement repeatedly is idempotent")
    func idempotent() {
        let manager = makeManager(sharedDefaults: isolated.defaults)

        manager.applyEntitlement(hasActive: true)
        manager.applyEntitlement(hasActive: true)

        #expect(manager.isSubscribed)
        #expect(isolated.defaults.bool(forKey: widgetKey))
    }

    @Test("an entitlement without a transaction still unlocks")
    func entitlementWithoutTransaction() {
        let manager = makeManager(sharedDefaults: isolated.defaults)

        manager.applyEntitlement(hasActive: true, latest: nil)

        #expect(manager.isSubscribed)
        #expect(manager.activeTransaction == nil)
    }

    @Test("an unavailable App Group store still updates in-process state")
    func missingAppGroupStore() {
        let manager = makeManager(sharedDefaults: nil)

        manager.applyEntitlement(hasActive: true)

        #expect(manager.isSubscribed)
    }

    @Test("the three product identifiers the paywall asks for")
    func productIdentifiers() {
        #expect(SubscriptionManager.productIDs == [
            "dayssince.weekly",
            "dayssince.monthly",
            "dayssince.annual",
        ])
    }
}
