@testable import DaysSince
import Foundation
import StoreKit
import StoreKitTest
import Testing

/// Global tier: `SKTestSession` installs a process-wide StoreKit environment, so these must
/// not run alongside anything else touching StoreKit. Products come from
/// `Configuration/DaysSince.storekit`, which is bundled into the test target.
///
/// Never assign `session.failTransactionsEnabled` here. On this toolchain the *setter* wedges
/// the session — writing even `false` makes the next `purchase()` throw `StoreKitError.unknown`,
/// which reads as a legitimate purchase failure. A "failed purchase" test built on it passes
/// vacuously while quietly breaking every other purchase in the process.
/// `Scripts/test.sh` skips this whole suite when `$CI` is set. A hosted runner cannot host a
/// StoreKit test environment: `SKTestSession` constructs, but every mutation then fails with
/// `SKInternalErrorDomain Code=3` ("Error saving configuration file") and the `purchase()` that
/// follows never returns — a job hung for 23 minutes before being cancelled rather than failing.
/// The skip lives in the script rather than in a `.disabled(if:)` trait because the condition
/// cannot be read from here: tests run in a separate process inside the simulator, which inherits
/// neither the shell's environment nor `TEST_RUNNER_`-prefixed settings.
/// Entitlement mirroring is covered without StoreKit by `SubscriptionEntitlementTests`.
extension GlobalStateSuite {

    @Suite("Subscription StoreKit")
    @MainActor
    struct SubscriptionStoreKitTests {

        private let isolated = IsolatedDefaults()
        private let session: SKTestSession

        init() async throws {
            session = try SKTestSession(configurationFileNamed: "DaysSince")
            session.resetToDefaultState()
            session.disableDialogs = true
            session.clearTransactions()
            await Self.waitForEmptyEntitlements()
        }

        /// `SKTestSession` mutations reach `Transaction.currentEntitlements` asynchronously.
        /// Without draining first, a transaction left by the previous test can still be
        /// visible, which made this suite pass on one run and fail on the next.
        private static func waitForEmptyEntitlements(attempts: Int = 50) async {
            for _ in 0 ..< attempts {
                var count = 0
                for await _ in StoreKit.Transaction.currentEntitlements { count += 1 }
                if count == 0 { return }
                try? await Task.sleep(for: .milliseconds(20))
            }
        }

        private func makeManager() -> SubscriptionManager {
            SubscriptionManager(
                sharedDefaults: isolated.defaults,
                notifier: SpyPurchaseNotifier(),
                autoStart: false
            )
        }

        // MARK: - Loading

        @Test("all three configured products load")
        func productsLoad() async {
            let manager = makeManager()

            await manager.loadProducts()

            #expect(Set(manager.products.map(\.id)) == Set(SubscriptionManager.productIDs))
        }

        @Test("products are ordered cheapest first, as the pricing cards expect")
        func productsSortedByPrice() async {
            let manager = makeManager()

            await manager.loadProducts()

            #expect(manager.products.map(\.id) == [
                "dayssince.weekly",
                "dayssince.monthly",
                "dayssince.annual",
            ])
            #expect(manager.products.map(\.displayPrice) == ["$2.99", "$4.99", "$19.99"])
        }

        @Test("every product is a renewing subscription in one group")
        func productsAreSubscriptions() async throws {
            let manager = makeManager()
            await manager.loadProducts()

            let groupIDs = try manager.products.map {
                try #require($0.subscription).subscriptionGroupID
            }

            #expect(groupIDs.count == 3)
            #expect(Set(groupIDs).count == 1)
        }

        @Test("a first-time buyer is offered the introductory offer")
        func introEligibility() async {
            let manager = makeManager()

            await manager.loadProducts()

            #expect(manager.isEligibleForIntro)
        }

        // MARK: - Purchasing

        @Test("a completed purchase unlocks Pro and mirrors it for the widgets")
        func purchaseUnlocks() async throws {
            let manager = makeManager()
            await manager.loadProducts()
            let weekly = try #require(manager.product(for: "dayssince.weekly"))

            let purchased = try await manager.purchase(weekly)

            #expect(purchased)
            #expect(manager.isSubscribed)
            #expect(isolated.defaults.bool(forKey: "dayssince_subscribed"))
            #expect(manager.activeTransaction?.productID == "dayssince.weekly")
        }

        @Test("a purchase held for approval does not unlock Pro")
        func askToBuyStaysLocked() async throws {
            session.askToBuyEnabled = true
            let manager = makeManager()
            await manager.loadProducts()
            let weekly = try #require(manager.product(for: "dayssince.weekly"))

            let purchased = try await manager.purchase(weekly)

            #expect(!purchased)
            #expect(!manager.isSubscribed)
            #expect(!isolated.defaults.bool(forKey: "dayssince_subscribed"))
        }

        @Test("a purchase notification reports the product bought")
        func purchaseNotifies() async throws {
            let notifier = SpyPurchaseNotifier()
            let manager = SubscriptionManager(
                sharedDefaults: isolated.defaults,
                notifier: notifier,
                autoStart: false
            )
            await manager.loadProducts()
            let annual = try #require(manager.product(for: "dayssince.annual"))

            _ = try await manager.purchase(annual)

            #expect(notifier.sent.count == 1)
            #expect(notifier.sent.first?.title == "New Subscription")
            #expect(notifier.sent.first?.body.contains("$19.99") == true)
        }

        // MARK: - Losing access

        /// Expiry, refund and revocation all reach our code the same way: the transaction
        /// stops appearing in `currentEntitlements`. `clearTransactions()` is what actually
        /// produces that in `SKTestSession` — `expireSubscription(productIdentifier:)` and
        /// `refundTransaction(identifier:)` are silent no-ops on this toolchain (verified:
        /// the transaction keeps its future expiry date and a nil revocation date), so
        /// asserting through them would pass vacuously.
        @Test("an entitlement that disappears revokes Pro and clears the widget mirror")
        func lostEntitlementRevokes() async throws {
            let manager = makeManager()
            await manager.loadProducts()
            _ = try await manager.purchase(try #require(manager.product(for: "dayssince.weekly")))
            #expect(isolated.defaults.bool(forKey: "dayssince_subscribed"))

            session.clearTransactions()
            await Self.waitForEmptyEntitlements()
            await manager.updateSubscriptionStatus()

            #expect(!manager.isSubscribed)
            #expect(manager.activeTransaction == nil)
            #expect(isolated.defaults.object(forKey: "dayssince_subscribed") as? Bool == false)
        }

        // MARK: - Restoring

        @Test("a fresh install with no purchases stays locked")
        func noEntitlementStaysLocked() async {
            let manager = makeManager()

            await manager.updateSubscriptionStatus()

            #expect(!manager.isSubscribed)
        }

        @Test("restore re-reads an existing entitlement on a fresh manager")
        func restoreRecoversEntitlement() async throws {
            let buyer = makeManager()
            await buyer.loadProducts()
            _ = try await buyer.purchase(try #require(buyer.product(for: "dayssince.annual")))

            let reinstalled = makeManager()
            await reinstalled.restorePurchases()

            #expect(reinstalled.isSubscribed)
            #expect(reinstalled.activeTransaction?.productID == "dayssince.annual")
        }
    }
}
